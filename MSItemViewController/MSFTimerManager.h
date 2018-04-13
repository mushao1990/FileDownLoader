//
//  MSFTimerManager.h
//  MSItemViewController
//
//  Created by apple on 2017/12/19.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MSFTimerManagerCallBack)();

@interface MSFTimerManager : NSObject

@property (nonatomic, strong, readonly) NSTimer    * timer;

@property (nonatomic, copy) MSFTimerManagerCallBack   callBack;//

/**
 开始计时
 
 @param timeInterVal 时间间隔
 */
- (void)startWithTimeInterVal:(NSTimeInterval)timeInterVal andBlock:(MSFTimerManagerCallBack)block;

/**
 定时器暂停计时
 */
- (void)timerPause;

/**
 定时器继续计时
 */
- (void)timerContinue;

/**
 定时器结束 - timer会被销毁
 */
- (void)timerStop;

@end
