//
//  MSHTTPResponseSerializer.m
//  MSItemViewController
//
//  Created by apple on 2018/7/11.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import "MSHTTPResponseSerializer.h"
NSString * const MSURLResponseSerializationErrorDomain = @"com.mushao.response";
NSString * const MSNetworkingOperationFailingURLResponseErrorKey = @"com.mushao.response.error.response";
NSString * const MSNetworkingOperationFailingURLResponseDataErrorKey = @"com.mushao.response.error.data";

static NSError * AFErrorWithUnderlyingError(NSError *error, NSError *underlyingError) {
    if (!error) {
        return underlyingError;
    }
    
    if (!underlyingError || error.userInfo[NSUnderlyingErrorKey]) {
        return error;
    }
    
    NSMutableDictionary *mutableUserInfo = [error.userInfo mutableCopy];
    mutableUserInfo[NSUnderlyingErrorKey] = underlyingError;
    
    return [[NSError alloc] initWithDomain:error.domain code:error.code userInfo:mutableUserInfo];
}

static BOOL AFErrorOrUnderlyingErrorHasCodeInDomain(NSError *error, NSInteger code, NSString *domain) {
    if ([error.domain isEqualToString:domain] && error.code == code) {
        return YES;
    } else if (error.userInfo[NSUnderlyingErrorKey]) {
        return AFErrorOrUnderlyingErrorHasCodeInDomain(error.userInfo[NSUnderlyingErrorKey], code, domain);
    }
    
    return NO;
}

static id AFJSONObjectByRemovingKeysWithNullValues(id JSONObject, NSJSONReadingOptions readingOptions) {
    if ([JSONObject isKindOfClass:[NSArray class]]) {
        NSMutableArray *mutableArray = [NSMutableArray arrayWithCapacity:[(NSArray *)JSONObject count]];
        for (id value in (NSArray *)JSONObject) {
            [mutableArray addObject:AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions)];
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableArray : [NSArray arrayWithArray:mutableArray];
    } else if ([JSONObject isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *mutableDictionary = [NSMutableDictionary dictionaryWithDictionary:JSONObject];
        for (id <NSCopying> key in [(NSDictionary *)JSONObject allKeys]) {
            id value = (NSDictionary *)JSONObject[key];
            if (!value || [value isEqual:[NSNull null]]) {
                [mutableDictionary removeObjectForKey:key];
            } else if ([value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSDictionary class]]) {
                mutableDictionary[key] = AFJSONObjectByRemovingKeysWithNullValues(value, readingOptions);
            }
        }
        
        return (readingOptions & NSJSONReadingMutableContainers) ? mutableDictionary : [NSDictionary dictionaryWithDictionary:mutableDictionary];
    }
    
    return JSONObject;
}

@implementation MSHTTPResponseSerializer

+ (instancetype)serializer {
    return [[self alloc] init];
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.stringEncoding = NSUTF8StringEncoding;
    
    self.acceptableStatusCodes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(200, 100)];
    self.acceptableContentTypes = nil;
    
    return self;
}

#pragma mark -

- (BOOL)validateResponse:(NSHTTPURLResponse *)response
                    data:(NSData *)data
                   error:(NSError * __autoreleasing *)error
{
    BOOL responseIsValid = YES;
    NSError *validationError = nil;
    
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
        if (self.acceptableContentTypes && ![self.acceptableContentTypes containsObject:[response MIMEType]] &&
            !([response MIMEType] == nil && [data length] == 0)) {
            
            if ([data length] > 0 && [response URL]) {
                NSMutableDictionary *mutableUserInfo = [@{
                                                          NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: unacceptable content-type: %@", @"MSNetwork", nil), [response MIMEType]],
                                                          NSURLErrorFailingURLErrorKey:[response URL],
                                                          MSNetworkingOperationFailingURLResponseErrorKey: response,
                                                          } mutableCopy];
                if (data) {
                    mutableUserInfo[MSNetworkingOperationFailingURLResponseDataErrorKey] = data;
                }
                
                validationError = AFErrorWithUnderlyingError([NSError errorWithDomain:MSURLResponseSerializationErrorDomain code:NSURLErrorCannotDecodeContentData userInfo:mutableUserInfo], validationError);
            }
            
            responseIsValid = NO;
        }
        
        if (self.acceptableStatusCodes && ![self.acceptableStatusCodes containsIndex:(NSUInteger)response.statusCode] && [response URL]) {
            NSMutableDictionary *mutableUserInfo = [@{
                                                      NSLocalizedDescriptionKey: [NSString stringWithFormat:NSLocalizedStringFromTable(@"Request failed: %@ (%ld)", @"AFNetworking", nil), [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode], (long)response.statusCode],
                                                      NSURLErrorFailingURLErrorKey:[response URL],
                                                      MSNetworkingOperationFailingURLResponseErrorKey: response,
                                                      } mutableCopy];
            
            if (data) {
                mutableUserInfo[MSNetworkingOperationFailingURLResponseDataErrorKey] = data;
            }
            
            validationError = AFErrorWithUnderlyingError([NSError errorWithDomain:MSURLResponseSerializationErrorDomain code:NSURLErrorBadServerResponse userInfo:mutableUserInfo], validationError);
            
            responseIsValid = NO;
        }
    }
    
    if (error && !responseIsValid) {
        *error = validationError;
    }
    
    return responseIsValid;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    [self validateResponse:(NSHTTPURLResponse *)response data:data error:error];
    
    return data;
}

@end

@implementation MSJSONResponseSerializer

+ (instancetype)serializer {
    return [self serializerWithReadingOptions:(NSJSONReadingOptions)0];
}

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions {
    MSJSONResponseSerializer *serializer = [[self alloc] init];
    serializer.readingOptions = readingOptions;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", nil];
    
    return self;
}

#pragma mark - MSURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MSURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    id responseObject = nil;
    NSError *serializationError = nil;
    // Workaround for behavior of Rails to return a single space for `head :ok` (a workaround for a bug in Safari), which is not interpreted as valid input by NSJSONSerialization.
    // See https://github.com/rails/rails/issues/1742
    BOOL isSpace = [data isEqualToData:[NSData dataWithBytes:" " length:1]];
    if (data.length > 0 && !isSpace) {
        responseObject = [NSJSONSerialization JSONObjectWithData:data options:self.readingOptions error:&serializationError];
    } else {
        return nil;
    }
    
    if (self.removesKeysWithNullValues && responseObject) {
        responseObject = AFJSONObjectByRemovingKeysWithNullValues(responseObject, self.readingOptions);
    }
    
    if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }
    
    return responseObject;
}

@end

@implementation MSXMLResponseSerializer

+ (instancetype)serializer {
    MSXMLResponseSerializer *serializer = [[self alloc] init];
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSHTTPURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MSURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    return [[NSXMLParser alloc] initWithData:data];
}

@end

#pragma mark -

#ifdef __MAC_OS_X_VERSION_MIN_REQUIRED

@implementation MSXMLDocumentResponseSerializer

+ (instancetype)serializer {
    return [self serializerWithXMLDocumentOptions:0];
}

+ (instancetype)serializerWithXMLDocumentOptions:(NSUInteger)mask {
    MSXMLDocumentResponseSerializer *serializer = [[self alloc] init];
    serializer.options = mask;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/xml", @"text/xml", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MSURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    NSError *serializationError = nil;
    NSXMLDocument *document = [[NSXMLDocument alloc] initWithData:data options:self.options error:&serializationError];
    
    if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }
    
    return document;
}

@end

#endif

#pragma mark -

@implementation MSPropertyListResponseSerializer

+ (instancetype)serializer {
    return [self serializerWithFormat:NSPropertyListXMLFormat_v1_0 readOptions:0];
}

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions
{
    MSPropertyListResponseSerializer *serializer = [[self alloc] init];
    serializer.format = format;
    serializer.readOptions = readOptions;
    
    return serializer;
}

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/x-plist", nil];
    
    return self;
}

#pragma mark - AFURLResponseSerialization

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MSURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
    id responseObject;
    NSError *serializationError = nil;
    
    if (data) {
        responseObject = [NSPropertyListSerialization propertyListWithData:data options:self.readOptions format:NULL error:&serializationError];
    }
    
    if (error) {
        *error = AFErrorWithUnderlyingError(serializationError, *error);
    }
    
    return responseObject;
}

@end

#pragma mark -

#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

@interface UIImage (MSNetworkSafeImageLoading)
+ (UIImage *)ms_safeImageWithData:(NSData *)data;
@end

static NSLock* imageLock = nil;

@implementation UIImage (MSNetworkSafeImageLoading)

+ (UIImage *)ms_safeImageWithData:(NSData *)data {
    UIImage* image = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imageLock = [[NSLock alloc] init];
    });
    
    [imageLock lock];
    image = [UIImage imageWithData:data];
    [imageLock unlock];
    return image;
}

@end

static UIImage * MSImageWithDataAtScale(NSData *data, CGFloat scale) {
    UIImage *image = [UIImage ms_safeImageWithData:data];
    if (image.images) {
        return image;
    }
    
    return [[UIImage alloc] initWithCGImage:[image CGImage] scale:scale orientation:image.imageOrientation];
}

static UIImage * MSInflatedImageFromResponseWithDataAtScale(NSHTTPURLResponse *response, NSData *data, CGFloat scale) {
    if (!data || [data length] == 0) {
        return nil;
    }
    
    CGImageRef imageRef = NULL;
    CGDataProviderRef dataProvider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    if ([response.MIMEType isEqualToString:@"image/png"]) {
        imageRef = CGImageCreateWithPNGDataProvider(dataProvider,  NULL, true, kCGRenderingIntentDefault);
    } else if ([response.MIMEType isEqualToString:@"image/jpeg"]) {
        imageRef = CGImageCreateWithJPEGDataProvider(dataProvider, NULL, true, kCGRenderingIntentDefault);
        
        if (imageRef) {
            CGColorSpaceRef imageColorSpace = CGImageGetColorSpace(imageRef);
            CGColorSpaceModel imageColorSpaceModel = CGColorSpaceGetModel(imageColorSpace);
            
            // CGImageCreateWithJPEGDataProvider does not properly handle CMKY, so fall back to AFImageWithDataAtScale
            if (imageColorSpaceModel == kCGColorSpaceModelCMYK) {
                CGImageRelease(imageRef);
                imageRef = NULL;
            }
        }
    }
    
    CGDataProviderRelease(dataProvider);
    
    UIImage *image = MSImageWithDataAtScale(data, scale);
    if (!imageRef) {
        if (image.images || !image) {
            return image;
        }
        
        imageRef = CGImageCreateCopy([image CGImage]);
        if (!imageRef) {
            return nil;
        }
    }
    
    size_t width = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    
    if (width * height > 1024 * 1024 || bitsPerComponent > 8) {
        CGImageRelease(imageRef);
        
        return image;
    }
    
    // CGImageGetBytesPerRow() calculates incorrectly in iOS 5.0, so defer to CGBitmapContextCreate
    size_t bytesPerRow = 0;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorSpaceModel colorSpaceModel = CGColorSpaceGetModel(colorSpace);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    if (colorSpaceModel == kCGColorSpaceModelRGB) {
        uint32_t alpha = (bitmapInfo & kCGBitmapAlphaInfoMask);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wassign-enum"
        if (alpha == kCGImageAlphaNone) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaNoneSkipFirst;
        } else if (!(alpha == kCGImageAlphaNoneSkipFirst || alpha == kCGImageAlphaNoneSkipLast)) {
            bitmapInfo &= ~kCGBitmapAlphaInfoMask;
            bitmapInfo |= kCGImageAlphaPremultipliedFirst;
        }
#pragma clang diagnostic pop
    }
    
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, bitmapInfo);
    
    CGColorSpaceRelease(colorSpace);
    
    if (!context) {
        CGImageRelease(imageRef);
        
        return image;
    }
    
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, width, height), imageRef);
    CGImageRef inflatedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *inflatedImage = [[UIImage alloc] initWithCGImage:inflatedImageRef scale:scale orientation:image.imageOrientation];
    
    CGImageRelease(inflatedImageRef);
    CGImageRelease(imageRef);
    
    return inflatedImage;
}
#endif


@implementation MSImageResponseSerializer

- (instancetype)init {
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"image/tiff", @"image/jpeg", @"image/gif", @"image/png", @"image/ico", @"image/x-icon", @"image/bmp", @"image/x-bmp", @"image/x-xbitmap", @"image/x-win-bitmap", nil];
    
#if TARGET_OS_IOS || TARGET_OS_TV
    self.imageScale = [[UIScreen mainScreen] scale];
    self.automaticallyInflatesResponseImage = YES;
#elif TARGET_OS_WATCH
    self.imageScale = [[WKInterfaceDevice currentDevice] screenScale];
    self.automaticallyInflatesResponseImage = YES;
#endif
    
    return self;
}

#pragma mark - AFURLResponseSerializer

- (id)responseObjectForResponse:(NSURLResponse *)response
                           data:(NSData *)data
                          error:(NSError *__autoreleasing *)error
{
    if (![self validateResponse:(NSHTTPURLResponse *)response data:data error:error]) {
        if (!error || AFErrorOrUnderlyingErrorHasCodeInDomain(*error, NSURLErrorCannotDecodeContentData, MSURLResponseSerializationErrorDomain)) {
            return nil;
        }
    }
    
#if TARGET_OS_IOS || TARGET_OS_TV || TARGET_OS_WATCH
    if (self.automaticallyInflatesResponseImage) {
        return MSInflatedImageFromResponseWithDataAtScale((NSHTTPURLResponse *)response, data, self.imageScale);
    } else {
        return MSImageWithDataAtScale(data, self.imageScale);
    }
#else
    // Ensure that the image is set to it's correct pixel width and height
    NSBitmapImageRep *bitimage = [[NSBitmapImageRep alloc] initWithData:data];
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([bitimage pixelsWide], [bitimage pixelsHigh])];
    [image addRepresentation:bitimage];
    
    return image;
#endif
    
    return nil;
}

@end

