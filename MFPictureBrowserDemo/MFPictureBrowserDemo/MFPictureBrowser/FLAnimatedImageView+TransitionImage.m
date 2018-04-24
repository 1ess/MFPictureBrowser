
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "FLAnimatedImageView+TransitionImage.h"

@implementation FLAnimatedImageView (TransitionImage)

- (void)animatedTransitionAnimatedImage:(FLAnimatedImage *)animatedImage {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.animatedImage = animatedImage;
                    } completion:NULL];
}

- (void)animatedTransitionImage:(UIImage *)image {
    [UIView transitionWithView:self
                      duration:0.15f
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.image = image;
                    } completion:NULL];
}

@end
