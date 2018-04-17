//
//  NSTimer+MFWeakTimer.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "NSTimer+MFWeakTimer.h"

@implementation NSTimer (MFWeakTimer)
+ (NSTimer *_Nonnull)mf_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^_Nonnull)(NSTimer * _Nonnull timer))block {
    if (@available(iOS 10.0, *)) {
        return [self scheduledTimerWithTimeInterval:interval repeats:repeats block:[block copy]];
    }else {
        return [self scheduledTimerWithTimeInterval:interval target:self selector:@selector(timerhandleInvoke:) userInfo:[block copy] repeats:repeats];
    }
}

+ (void)timerhandleInvoke:(NSTimer *)timer {
    void (^block)(void) = timer.userInfo;
    if (block) {
        block();
    }
}
@end
