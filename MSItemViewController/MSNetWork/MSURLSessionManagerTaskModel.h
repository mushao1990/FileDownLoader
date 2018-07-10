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

@property (nonatomic, copy) MSURLSessionProgressBlock    uploadProgress;//

@property (nonatomic, copy) MSURLSessionProgressBlock    downloadProgress;//

@property (nonatomic, copy) MSURLSessionTaskCompletionBlock    completionBlock;//

- (void)addProgressForTask:(NSURLSessionTask *)task;

- (void)removeProgressForTask:(NSURLSessionTask *)task;

@end
