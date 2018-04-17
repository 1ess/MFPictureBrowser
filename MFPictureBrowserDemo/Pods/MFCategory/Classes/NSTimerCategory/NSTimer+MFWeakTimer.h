//
//  NSTimer+MFWeakTimer.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (MFWeakTimer)
+ (NSTimer *_Nonnull)mf_scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^_Nonnull)(NSTimer * _Nonnull timer))block;
@end
