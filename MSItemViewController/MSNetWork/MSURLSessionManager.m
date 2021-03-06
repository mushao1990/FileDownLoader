//
//  MSURLSessionManager.m
//  MSItemViewController
//
//  Created by apple on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import "MSURLSessionManager.h"
#import "MSURLSessionManagerTaskModel.h"

#ifndef NSFoundationVersionNumber_iOS_8_0
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug 1140.11
#else
#define NSFoundationVersionNumber_With_Fixed_5871104061079552_bug NSFoundationVersionNumber_iOS_8_0
#endif

static dispatch_queue_t url_session_manager_creation_queue() {
    static dispatch_queue_t af_url_session_manager_creation_queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_creation_queue = dispatch_queue_create("com.alamofire.networking.session.manager.creation", DISPATCH_QUEUE_SERIAL);
    });
    
    return af_url_session_manager_creation_queue;
}

static void url_session_manager_create_task_safely(dispatch_block_t block) {
    if (NSFoundationVersionNumber < NSFoundationVersionNumber_With_Fixed_5871104061079552_bug) {
        // Fix of bug
        // Open Radar:http://openradar.appspot.com/radar?id=5871104061079552 (status: Fixed in iOS8)
        // Issue about:https://github.com/AFNetworking/AFNetworking/issues/2093
        dispatch_sync(url_session_manager_creation_queue(), block);
    } else {
        block();
    }
}

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
    __block NSURLSessionDataTask *dataTask = nil;
    url_session_manager_create_task_safely(^{
        dataTask = [self.session dataTaskWithRequest:request];
    });
    
    [self addTaskModelForDataTask:dataTask uploadProgress:uploadProgressBlock downloadProgress:downloadProgressBlock completionHandler:completionHandler];
    
    return dataTask;
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
        if ([self.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
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
        [taskModel URLSession:session task:task didCompleteWithError:error];
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
        [taskModel URLSession:session dataTask:dataTask didReceiveData:data];
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
    taskModel.uploadProgressBlock = uploadProgressBlock;
    taskModel.downloadProgressBlock = downloadProgressBlock;
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
    
        self.responseSerialization = [MSJSONResponseSerializer serializer];
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

- (NSMutableDictionary *)taskModelsDictionary {
    if (!_taskModelsDictionary) {
        _taskModelsDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    }
    return _taskModelsDictionary;
}

@end
