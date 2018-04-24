//
//  UIView+MFExpandTouchSize.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "UIView+MFExpandTouchSize.h"
#import <objc/runtime.h>

void expandTouch_swizzingMethod(Class class,SEL orig,SEL new){
    Method origMethod = class_getInstanceMethod(class, orig);
    Method newMethod = class_getInstanceMethod(class, new);
    if (class_addMethod(class, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))) {
        class_replaceMethod(class, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    }else{
        method_exchangeImplementations(origMethod, newMethod);
    }
}

@implementation UIView (MFExpandTouchSize)
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        expandTouch_swizzingMethod([self class], @selector(pointInside:withEvent:), @selector(mf_expandTouchPointInside:withEvent:));
    });
}

- (BOOL)mf_expandTouchPointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.expandTouchInset, UIEdgeInsetsZero)||self.hidden||([self isKindOfClass:[UIControl class]] && !((UIControl *)self).enabled)) {
        [self mf_expandTouchPointInside:point withEvent:event];
    }
    CGRect hitRect = UIEdgeInsetsInsetRect(self.bounds, self.expandTouchInset);
    hitRect.size.width  = MAX(hitRect.size.width, 0);
    hitRect.size.height = MAX(hitRect.size.height, 0);
    return CGRectContainsPoint(hitRect, point);
}

- (void)setExpandTouchInset:(UIEdgeInsets)expandTouchInset {
    objc_setAssociatedObject(self, @selector(expandTouchInset), [NSValue valueWithUIEdgeInsets:expandTouchInset], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIEdgeInsets)expandTouchInset {
    return [objc_getAssociatedObject(self, _cmd) UIEdgeInsetsValue];
}
@end
