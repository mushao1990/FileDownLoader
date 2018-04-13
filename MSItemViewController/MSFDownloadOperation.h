//
//  MSFDownloadOperation.h
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    MSFDownloadStateReady = 0,//默认准备中
    MSFDownloadStateWaiting = 1,//排队中
    MSFDownloadStateLoading = 2,//下载中
    MSFDownloadStateComplete = 3,//完成
    MSFDownloadStateFailure = 4//下载失败
} MSFDownloadStateSatus;

static NSString    * MSF_DOWNLOADCOMPLETE_NOTIFICATION = @"MSF_DOWNLOADCOMPLETE_NOTIFICATION";

/**
 只负责  下载 暂停 文件写入 数据大小
 */
@interface MSFDownloadOperation : NSObject<NSURLSessionDataDelegate,NSCoding>

@property (nonatomic, strong) NSFileHandle    * fileHandle;//文件操作

@property (nonatomic, copy , readonly) NSString    * downloadUrlString;//下载地址

@property (nonatomic, strong) NSURLSessionDataTask    * downloadTask;//下载任务

@property (nonatomic, strong) NSURLSession    * downloadSession;//

@property (nonatomic, assign) MSFDownloadStateSatus    downloadState;//

@property (nonatomic, assign) int64_t    recivedSize;//已经收到的文件大小

@property (nonatomic, assign) int64_t    totalSize;//总共文件大小

/**
 根据一个urlString进行初始化

 @param urlString 下载地址
 @return 返回对象
 */
- (instancetype)initWithDownloadUrlString:(NSString *)urlString;

/**
 开始下载
 */
- (void)downloadBeigin;

/**
 取消下载
 */
- (void)downloadCancle;

@end
