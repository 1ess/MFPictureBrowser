//
//  UIColor+MFLDColor.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "UIColor+MFLDColor.h"

@implementation UIColor (MFLDColor)
- (BOOL)isLightColor {
    CGFloat components[3];
    [self p_getRGBComponents:components forColor:self];
    
    CGFloat num = components[0] + components[1] + components[2];
    if(num < 382)
        return NO;
    else
        return YES;
}

// get rgb value
-  (void)p_getRGBComponents:(CGFloat [3])components forColor:(UIColor *)color {
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1
    int bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast;
#else
    int bitmapInfo = kCGImageAlphaPremultipliedLast;
#endif
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char resultingPixel[4];
    CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                 1,
                                                 1,
                                                 8,
                                                 4,
                                                 rgbColorSpace,
                                                 bitmapInfo);
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
    CGContextRelease(context);
    CGColorSpaceRelease(rgbColorSpace);
    
    for (int component = 0; component < 3; component++) {
        components[component] = resultingPixel[component];
    }
}
@end
