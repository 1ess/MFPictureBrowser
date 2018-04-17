//
//  UIColor+MFHexColor.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (MFHexColor)
+ (UIColor *)colorWithHexString:(NSString *)hexString;
+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;
- (NSString *)hexString;
@end
