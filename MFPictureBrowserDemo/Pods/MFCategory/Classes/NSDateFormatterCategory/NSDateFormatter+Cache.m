//
//  NSDateFormatter+Cache.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "NSDateFormatter+Cache.h"

@implementation NSDateFormatter (Cache)
+ (instancetype)sharedInstance {
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        
    });
    return formatter;
}


@end
