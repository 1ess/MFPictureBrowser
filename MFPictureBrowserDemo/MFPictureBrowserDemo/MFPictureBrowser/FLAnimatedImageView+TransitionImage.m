

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

@end
