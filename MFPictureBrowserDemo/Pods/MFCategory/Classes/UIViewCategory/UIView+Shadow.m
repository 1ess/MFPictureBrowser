//
//  UIView+Shadow.m
//  Created by pipelining.
//  Copyright © 2018年 GodzzZZZ. All rights reserved.
//

#import "UIView+Shadow.h"

@implementation UIView (Shadow)
- (void)addShadowWithColor:(UIColor *)shadowColor {
    self.layer.shadowColor = shadowColor.CGColor;
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.7;
    self.layer.shadowOffset = CGSizeMake(0, 5);
}

- (void)removeShadow {
    self.layer.shadowOpacity = 0;
}

@end
