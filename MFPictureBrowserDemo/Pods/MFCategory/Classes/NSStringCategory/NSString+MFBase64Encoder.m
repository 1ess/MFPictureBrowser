//
//  NSString+MFBase64Encoder.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "NSString+MFBase64Encoder.h"

@implementation NSString (MFBase64Encoder)
- (NSString *)base64Encoded {
    NSData *data = [self dataUsingEncoding:NSUTF8StringEncoding];
    return [data base64EncodedStringWithOptions:0];
}
@end
