//
//  UIImage+Current.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "UIImage+Current.h"

@implementation UIImage (Current)
+ (UIImage *)getImageFromCurrentView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 0.0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
@end
