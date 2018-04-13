//
//  MSFDownloadOperation.m
//  MSItemViewController
//
//  Created by apple on 2017/12/20.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "MSFDownloadOperation.h"
#import "NSString+MSFStringConvience.h"

@implementation MSFDownloadOperation

- (instancetype)initWithDownloadUrlString:(NSString *)urlString {
    if (self = [super init]) {
        _downloadUrlString = urlString;
        _downloadState = MSFDownloadStateReady;
    }
    return self;
}

- (void)downloadBeigin {
    NSMutableURLRequest    * urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.downloadUrlString]];

    NSString    * range = [NSString stringWithFormat:@"bytes=%zd-",self.recivedSize];
    [urlRequest setValue:range forHTTPHeaderField:@"Range"];
    
    NSURLSession    * session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
    self.downloadSession = session;
    self.downloadTask = [session dataTaskWithRequest:urlRequest];
    [self.downloadTask resume];
}

- (void)downloadCancle {
    // 取消下载了
    [self.downloadTask cancel];
}

#pragma mark----------------------urlSessionDelegate

// 开始收到服务器响应
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler {
    
    completionHandler(NSURLSessionResponseAllow);
    
    int64_t   localRecive = [self getTheLocalFileSize];
    self.totalSize = dataTask.countOfBytesExpectedToReceive + localRecive;
    self.recivedSize = localRecive;
}
// 收到数据
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    [self.fileHandle seekToEndOfFile];
    [self.fileHandle writeData:data];
    
    self.recivedSize += data.length;
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    self.downloadSession = nil;
    [self.fileHandle closeFile];
    self.fileHandle = nil;
    if (error.code == NSURLErrorCancelled) {
        self.downloadState = MSFDownloadStateReady;
    }
    if (!error) {
        self.downloadState = MSFDownloadStateComplete;
    }
    else {
        self.downloadState = MSFDownloadStateFailure;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:MSF_DOWNLOADCOMPLETE_NOTIFICATION object:self];// 发送成功的通知
}

- (NSFileHandle *)fileHandle {
    if (!_fileHandle) {
        
        NSString    * path = [self filePathByDownloadUrlString];
        NSError   * error = nil;
        _fileHandle = [NSFileHandle fileHandleForWritingToURL:[NSURL fileURLWithPath:path isDirectory:NO] error:&error];
    }
    return _fileHandle;
}

- (int64_t)getTheLocalFileSize {

    NSString    * path = [self filePathByDownloadUrlString];
    NSFileManager    * manager = [NSFileManager defaultManager];
    return [[manager attributesOfItemAtPath:path error:nil] fileSize];
}

#pragma mark---------------------------
- (NSString *)filePathByDownloadUrlString {
    NSString    * md5_string = [NSString md5String:self.downloadUrlString];
    NSString    * fileName = self.downloadUrlString.lastPathComponent;
    NSString    * path = [NSString getTheDestionPathByFolder:[NSString stringWithFormat:@"MSFDownload/%@",md5_string] ByFileName:fileName];
    return path;
}

#pragma mark---------------nscoding----

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeInt64:_recivedSize forKey:@"recivedSize"];
    [aCoder encodeInt64:_totalSize forKey:@"totalSize"];
    [aCoder encodeInteger:_downloadState forKey:@"downloadState"];
    [aCoder encodeObject:_downloadUrlString forKey:@"downloadUrlString"];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
       _recivedSize = [aDecoder decodeInt64ForKey:@"recivedSize"];
       _totalSize = [aDecoder decodeInt64ForKey:@"totalSize"];
       _downloadUrlString = [aDecoder decodeObjectForKey:@"downloadUrlString"];
       _downloadState = [aDecoder decodeIntegerForKey:@"downloadState"];
    }
    return self;
}

@end
