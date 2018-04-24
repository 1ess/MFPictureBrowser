//
//  NSArray+Distinct.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "NSArray+Distinct.h"

@implementation NSArray (Distinct)
+ (NSArray *)distinctUnionOfArray:(NSArray *)originArray {
    return [originArray valueForKeyPath:@"@distinctUnionOfObjects.self"];
}
@end
