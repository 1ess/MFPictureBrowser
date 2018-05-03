
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "FLAnimatedImageView+TransitionImage.h"

@implementation FLAnimatedImageView (TransitionImage)
- (void)animatedTransitionImage:(FLAnimatedImage *)animatedImage {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.animatedImage = animatedImage;
                    } completion:NULL];
}
- (void)animatedTransitionNormalImage:(UIImage *)normalImage {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = normalImage;
                    } completion:NULL];
}
@end
