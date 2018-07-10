//
//  MSNetWork.h
//  MSItemViewController
//
//  Created by 慕少锋 on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void(^MSURLSessionProgressBlock)(NSProgress *);

typedef void (^MSURLSessionTaskCompletionBlock)(NSURLResponse *response, id responseObject, NSError *error);
