//
//  MSURLSessionManager.h
//  MSItemViewController
//
//  Created by apple on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSSecurityPolicy.h"
#import "MSURLRequestSerialization.h"
#import "MSURLResponseSerialization.h"
#import "MSNetWork.h"

/**
 用来管理NSURLSession
 目前不支持上传和下载
 */
@interface MSURLSessionManager : NSObject

@property (nonatomic, strong) MSURLRequestSerialization    * requestSerialization;// 请求解析器

@property (nonatomic, strong) MSURLResponseSerialization    * responseSerialization;// 响应解析器

@property (nonatomic, strong) MSSecurityPolicy    * securityPolicy;// 安全策略

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;

// 请求数据
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(MSURLSessionTaskCompletionBlock)completionHandler;
// 请求数据（带进度）
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(MSURLSessionProgressBlock)uploadProgressBlock
                             downloadProgress:(MSURLSessionProgressBlock)downloadProgressBlock
                            completionHandler:(MSURLSessionTaskCompletionBlock)completionHandler;

@end
