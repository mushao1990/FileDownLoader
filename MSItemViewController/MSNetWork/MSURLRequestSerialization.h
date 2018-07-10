//
//  MSURLRequestSerialization.h
//  MSItemViewController
//
//  Created by apple on 2018/7/10.
//  Copyright © 2018年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求解析类（主要是对参数做处理工作）
 */
@interface MSURLRequestSerialization : NSObject

+ (MSURLRequestSerialization *)defaultRequestSerialization;

@end
