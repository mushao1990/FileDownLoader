//
//  MSFDownloadManager.h
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MSFDownloadOperation;

/**
 下载工具管理类  管理单独的下载项
 */
@interface MSFDownloadManager : NSObject

@property (nonatomic, assign) NSInteger    maxConcurrent;//最大并发数 默认1

+ (instancetype)sharedManager;

- (void)cancleAllDownloads;//取消所有的下载

/**
 根据加密过的字符串或者下载链接地址开始下载，并返回一个操作对象
（先判断有没有加密过的字符串，如果没有，就根据urlString进行加密获得）
 @param md5String 加密过的字符串
 @param urlString 下载地址
 @return 返回的操作对象
 */
- (MSFDownloadOperation *)beginDownloadByMd5String:(NSString *)md5String orUrlString:(NSString *)urlString;
/*
 取消操作
 */
- (void)cancleDownloadByByMd5String:(NSString *)md5String orUrlString:(NSString *)urlString;

/**
 保存所有的下载操作
 */
- (void)saveTheOperations;

/**
 获取对应的下载操作对象
 */
- (MSFDownloadOperation *)getTheDownloadInfoByMd5String:(NSString *)md5String orUrlstring:(NSString *)urlString;

@end


