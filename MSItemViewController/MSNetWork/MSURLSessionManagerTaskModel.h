//
//  MSURLSessionManagerTaskModel.h
//  MSItemViewController
//
//  Created by 慕少锋 on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MSURLSessionManager.h"
#import "MSNetWork.h"
/**
 任务模型
 */
@interface MSURLSessionManagerTaskModel : NSObject

@property (nonatomic, weak) MSURLSessionManager    * manager;//

@property (nonatomic, copy) MSURLSessionProgressBlock    uploadProgressBlock;//

@property (nonatomic, copy) MSURLSessionProgressBlock    downloadProgressBlock;//

@property (nonatomic, copy) MSURLSessionTaskCompletionBlock    completionBlock;//

@property (nonatomic, strong) NSProgress    * uploadProgress;

@property (nonatomic, strong) NSProgress    * downloadProgress;

@property (nonatomic, strong) NSMutableData    * mutableData;//

- (void)addProgressForTask:(NSURLSessionTask *)task;

- (void)removeProgressForTask:(NSURLSessionTask *)task;

- (void)URLSession:(__unused NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error;

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;

@end
