//
//  NSString+MSFStringConvience.m
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "NSString+MSFStringConvience.h"
#import <CommonCrypto/CommonCrypto.h>


@implementation NSString (MSFStringConvience)

+ (NSString *)getTheFileSizeStringByUnit:(int64_t)fileLength {
    // mac电脑 显示的文件大小，是以1000位单位换算的
    if(fileLength >= pow(1000, 3))
        return [NSString stringWithFormat:@"%.2f GB",(fileLength / (float)pow(1000, 3))];
    else if(fileLength >= pow(1000, 2))
        return [NSString stringWithFormat:@"%.2f MB",(fileLength / (float)pow(1000, 2))];
    else if(fileLength >= 1000)
        return [NSString stringWithFormat:@"%.2f KB",(fileLength / (float)1000)];
    else {
        return [NSString stringWithFormat:@"%.2f Bytes",(float)fileLength];
    }
}

+ (NSString *)getTheDestionPathByFolder:(NSString *)defaultFolder ByFileName:(NSString *)name {
    
    NSString    * folder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory , NSUserDomainMask, YES) lastObject];
    
    folder = [folder stringByAppendingPathComponent:defaultFolder];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    folder = [folder stringByAppendingPathComponent:name];
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        [[NSFileManager defaultManager] createFileAtPath:folder contents:nil attributes:nil];
    }
    
    return folder;
}

+ (NSString *)md5String:(NSString *)string {
    if (!string) return nil;
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0],  result[1],  result[2],  result[3],
            result[4],  result[5],  result[6],  result[7],
            result[8],  result[9],  result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

@end
