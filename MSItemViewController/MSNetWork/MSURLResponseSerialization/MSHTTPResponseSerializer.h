//
//  MSHTTPResponseSerializer.h
//  MSItemViewController
//
//  Created by apple on 2018/7/11.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSURLResponseSerialization.h"
NS_ASSUME_NONNULL_BEGIN

@interface MSHTTPResponseSerializer : NSObject<MSURLResponseSerialization>

- (instancetype)init;

@property (nonatomic, assign) NSStringEncoding stringEncoding;

+ (instancetype)serializer;

@property (nonatomic, copy, nullable) NSIndexSet *acceptableStatusCodes;

@property (nonatomic, copy, nullable) NSSet <NSString *> *acceptableContentTypes;

- (BOOL)validateResponse:(nullable NSHTTPURLResponse *)response
                    data:(nullable NSData *)data
                   error:(NSError * _Nullable __autoreleasing *)error;

@end


@interface MSJSONResponseSerializer : MSHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSJSONReadingOptions readingOptions;

@property (nonatomic, assign) BOOL removesKeysWithNullValues;

+ (instancetype)serializerWithReadingOptions:(NSJSONReadingOptions)readingOptions;

@end

@interface MSXMLResponseSerializer : MSHTTPResponseSerializer

@end

@interface MSXMLDocumentResponseSerializer : MSHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSUInteger options;

+ (instancetype)serializerWithXMLDocumentOptions:(NSUInteger)mask;

@end

@interface MSPropertyListResponseSerializer : MSHTTPResponseSerializer

- (instancetype)init;

@property (nonatomic, assign) NSPropertyListFormat format;

@property (nonatomic, assign) NSPropertyListReadOptions readOptions;

+ (instancetype)serializerWithFormat:(NSPropertyListFormat)format
                         readOptions:(NSPropertyListReadOptions)readOptions;

@end

@interface MSImageResponseSerializer : MSHTTPResponseSerializer

@property (nonatomic, assign) float imageScale;

@property (nonatomic, assign) BOOL automaticallyInflatesResponseImage;

@end

NS_ASSUME_NONNULL_END
