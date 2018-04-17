//
//  NSData+MFHexString.m

//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MFHexString)
+ (NSData *)convertedToDataFromHexString:(NSString *)hexString;
@end
