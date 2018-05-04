
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <Foundation/Foundation.h>
typedef BOOL(^MFRunLoopDistributionUnit)(void);
@interface MFRunLoopDistribution : NSObject
+ (instancetype)sharedRunLoopDistribution;
- (void)addTask:(MFRunLoopDistributionUnit)unit withKey:(id)key;
- (void)removeAllTasks;
@end
