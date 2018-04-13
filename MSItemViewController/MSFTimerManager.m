//
//  MSFTimerManager.m
//  MSItemViewController
//
//  Created by apple on 2017/12/19.
//  Copyright © 2017年 Zhangmen. All rights reserved.
//

#import "MSFTimerManager.h"

@implementation MSFTimerManager

- (void)startWithTimeInterVal:(NSTimeInterval)timeInterVal andBlock:(MSFTimerManagerCallBack)block {
    
    _callBack = block;
    
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    
    _timer = [NSTimer timerWithTimeInterval:timeInterVal target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
    [_timer fire];
    
}

- (void)timerPause {
    if (_timer) {
        [_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)timerContinue {
    if (_timer) {
        [_timer setFireDate:[NSDate distantPast]];
    }
}

- (void)timerStop {
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)timerRun {
    if (_callBack) {
        _callBack();
    }
}

@end
