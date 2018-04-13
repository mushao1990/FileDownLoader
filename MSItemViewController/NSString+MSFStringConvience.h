//
//  NSString+MSFStringConvience.h
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MSFStringConvience)

/**
 根据文件大小，返回一个封装好的文件大小字符串 如： 123  返回 123KB

 @param fileLength 文件大小
 @return 返回
 */
+ (NSString *)getTheFileSizeStringByUnit:(int64_t)fileLength;

/**
 获取文件路径

 @param defaultFolder 文件夹
 @param name 文件名
 @return 返回文件路径
 */
+ (NSString *)getTheDestionPathByFolder:(NSString *)defaultFolder ByFileName:(NSString *)name;

/**
 对字符串加密

 @param string 要加密的字符串
 @return 返回结果
 */
+ (NSString *)md5String:(NSString *)string;

@end
