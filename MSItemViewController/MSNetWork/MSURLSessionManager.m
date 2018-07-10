//
//  MSURLSessionManager.m
//  MSItemViewController
//
//  Created by apple on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import "MSURLSessionManager.h"
#import "MSURLSessionManagerTaskModel.h"

@interface MSURLSessionManager()<NSURLSessionDelegate,NSURLSessionDataDelegate>

@property (nonatomic, strong) NSURLSession    * session;// 会话

@property (nonatomic, strong) NSURLSessionConfiguration    * sessionConfiguration; // 会话配置

@property (nonatomic, strong) NSOperationQueue    * operationQueue;// 代理回调所在队列

@property (nonatomic, strong) NSLock    * lock;// 锁

@property (nonatomic, strong) NSMutableDictionary    * taskModelsDictionary;// 任务模型字典

@end

@implementation MSURLSessionManager

- (void)dealloc {
    
}

// 请求数据
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                            completionHandler:(MSURLSessionTaskCompletionBlock)completionHandler {
    return [self dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:completionHandler];
}

// 请求数据（带进度）
- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(MSURLSessionProgressBlock)uploadProgressBlock
                             downloadProgress:(MSURLSessionProgressBlock)downloadProgressBlock
                            completionHandler:(MSURLSessionTaskCompletionBlock)completionHandler {
    return nil;
}

#pragma mark - NSURLSessionDelegate

- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error {

}

#pragma mark - NSURLSessionTaskDelegate

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
willPerformHTTPRedirection:(NSHTTPURLResponse *)response
        newRequest:(NSURLRequest *)request
 completionHandler:(void (^)(NSURLRequest *))completionHandler
{
    NSURLRequest *redirectRequest = request;
    if (completionHandler) {
        completionHandler(redirectRequest);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    __block NSURLCredential *credential = nil;
    
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        // [self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]
        if (1) {
            disposition = NSURLSessionAuthChallengeUseCredential;
            credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
        } else {
            disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
        }
    } else {
        disposition = NSURLSessionAuthChallengePerformDefaultHandling;
    }
    
    if (completionHandler) {
        completionHandler(disposition, credential);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
 needNewBodyStream:(void (^)(NSInputStream *bodyStream))completionHandler {
    NSInputStream *inputStream = nil;
    
    if (task.originalRequest.HTTPBodyStream && [task.originalRequest.HTTPBodyStream conformsToProtocol:@protocol(NSCopying)]) {
        inputStream = [task.originalRequest.HTTPBodyStream copy];
    }
    
    if (completionHandler) {
        completionHandler(inputStream);
    }
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {// 告诉任务模型
    MSURLSessionManagerTaskModel *taskModel = [self taskModelForTask:task];
    if (taskModel) {
        
    }
}

#pragma mark - NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    NSURLSessionResponseDisposition disposition = NSURLSessionResponseAllow;
    
    if (completionHandler) {
        completionHandler(disposition);
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didBecomeDownloadTask:(NSURLSessionDownloadTask *)downloadTask {

}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    // 告诉任务模型，收到数据了
    MSURLSessionManagerTaskModel *taskModel = [self taskModelForTask:dataTask];
    if (taskModel) {
        
    }
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    NSCachedURLResponse *cachedResponse = proposedResponse;
    if (completionHandler) {
        completionHandler(cachedResponse);
    }
}

#pragma mark---- private method

- (void)addTaskModelForDataTask:(NSURLSessionDataTask *)dataTask
                uploadProgress:(MSURLSessionProgressBlock) uploadProgressBlock
              downloadProgress:(MSURLSessionProgressBlock) downloadProgressBlock
             completionHandler:(MSURLSessionTaskCompletionBlock)completionHandler {
    MSURLSessionManagerTaskModel    * taskModel = [[MSURLSessionManagerTaskModel alloc] init];
    taskModel.manager = self;
    taskModel.uploadProgress = uploadProgressBlock;
    taskModel.downloadProgress = downloadProgressBlock;
    taskModel.completionBlock = completionHandler;
    [self setTaskModel:taskModel forTask:dataTask];
}

- (void)setTaskModel:(MSURLSessionManagerTaskModel *)taskModel forTask:(NSURLSessionDataTask *)task {
    [self.lock lock];
    self.taskModelsDictionary[@(task.taskIdentifier)] = taskModel;
    [taskModel addProgressForTask:task];
    [self.lock unlock];
}

- (MSURLSessionManagerTaskModel *)taskModelForTask:(NSURLSessionTask *)task {
    
    NSParameterAssert(task);
    
    MSURLSessionManagerTaskModel *taskModel = nil;
    [self.lock lock];
    taskModel = self.taskModelsDictionary[@(task.taskIdentifier)];
    [self.lock unlock];
    
    return taskModel;
}

- (void)removeTaskModelForTask:(NSURLSessionTask *)task {
    NSParameterAssert(task);
    
    MSURLSessionManagerTaskModel *taskModel = [self taskModelForTask:task];
    [self.lock lock];
    [taskModel removeProgressForTask:task];
    [self.taskModelsDictionary removeObjectForKey:@(task.taskIdentifier)];
    [self.lock unlock];
}

#pragma mark---- init

- (instancetype)init {
    return [self initWithSessionConfiguration:nil];
}

- (instancetype)initWithSessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {
    if (self = [super init]) {
        if (!configuration) {
            configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        }
        self.sessionConfiguration = configuration;
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.operationQueue.maxConcurrentOperationCount = 1;
        
        self.session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:self.operationQueue];
        
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"com.mushao.MSNetWorkLock";
        
        // 获取该会话所有正在执行的任务
        [self.session getTasksWithCompletionHandler:^(NSArray<NSURLSessionDataTask *> * _Nonnull dataTasks, NSArray<NSURLSessionUploadTask *> * _Nonnull uploadTasks, NSArray<NSURLSessionDownloadTask *> * _Nonnull downloadTasks) {
            for (NSURLSessionDataTask * dataTask in dataTasks) {
                [self addTaskModelForDataTask:dataTask uploadProgress:nil downloadProgress:nil completionHandler:nil];
            }
        }];
    }
    return self;
}

- (MSSecurityPolicy *)securityPolicy {
    if (!_securityPolicy) {
        _securityPolicy = [MSSecurityPolicy defaultPolicy];
    }
    return _securityPolicy;
}

- (MSURLResponseSerialization *)responseSerialization {
    if (!_responseSerialization) {
        _responseSerialization = [MSURLResponseSerialization defaultResponseSerialization];
    }
    return _responseSerialization;
}

- (MSURLRequestSerialization *)requestSerialization {
    if (!_requestSerialization) {
        _requestSerialization = [MSURLRequestSerialization defaultRequestSerialization];
    }
    return _requestSerialization;
}

- (NSMutableDictionary *)taskModelsDictionary {
    if (!_taskModelsDictionary) {
        _taskModelsDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _taskModelsDictionary;
}

@end
