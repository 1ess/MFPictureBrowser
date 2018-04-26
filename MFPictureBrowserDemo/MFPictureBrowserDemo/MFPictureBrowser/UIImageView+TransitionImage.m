
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "UIImageView+TransitionImage.h"

@implementation UIImageView (TransitionImage)

- (void)animatedTransitionImage:(UIImage *)image {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = image;
                    } completion:NULL];
}
@end
