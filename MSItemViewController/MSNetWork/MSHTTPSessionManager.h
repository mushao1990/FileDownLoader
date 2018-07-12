//
//  MSHTTPSessionManager.h
//  MSItemViewController
//
//  Created by 慕少锋 on 2018/7/12.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import "MSURLSessionManager.h"
#import "MSURLRequestSerialization.h"

@interface MSHTTPSessionManager : MSURLSessionManager<NSSecureCoding,NSCopying>

@property (nonatomic, strong) NSURL *baseURL;

@property (nonatomic, strong) id <MSURLRequestSerialization>  requestSerializer;

- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;

- (nullable NSURLSessionDataTask *)GET:(NSString *)URLString
                            parameters:(nullable id)parameters
                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                               success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                               failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

- (nullable NSURLSessionDataTask *)POST:(NSString *)URLString
                             parameters:(nullable id)parameters
                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                success:(nullable void (^)(NSURLSessionDataTask *task, id _Nullable responseObject))success
                                failure:(nullable void (^)(NSURLSessionDataTask * _Nullable task, NSError *error))failure;

@end
