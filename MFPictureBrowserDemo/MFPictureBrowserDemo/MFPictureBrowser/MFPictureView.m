
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureView.h"
#import "UIImageView+TransitionImage.h"
#import "UIImage+ForceDecoded.h"
#import "MFRunLoopDistribution.h"
#import "MFPictureBrowserMacro.h"
@interface MFPictureView()
<
UIScrollViewDelegate
>
@property (nonatomic, assign) CGSize showPictureSize;
@property (nonatomic, assign) BOOL doubleClicks;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign, getter = isAnimationInProgress) BOOL animationInProgress;
@property (nonatomic, assign, getter = isLoadingFinished) BOOL loadingFinished;
@property (nonatomic, assign, getter = isLocalImage) BOOL localImage;
@property (nonatomic, assign, getter = isGIF) BOOL GIF;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation MFPictureView

- (instancetype)initWithPictureModel:(id<MFPictureModelProtocol>)pictureModel {
    self = [super init];
    if (self) {
        self.localImage = false;
        if (pictureModel.imageName) {
            self.localImage = true;
        }
        self.GIF = false;
        if (pictureModel.imageType == MFImageTypeGIF) {
            self.GIF = true;
        }
        [self setupUI];
        self.pictureModel = pictureModel;
    }
    return self;
}

- (void)setupUI {
    self.delegate = self;
    self.alwaysBounceVertical = true;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = false;
    self.showsVerticalScrollIndicator = false;
    self.maximumZoomScale = 2;

    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = 3;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = true;
    _imageView = imageView;
    [self addSubview:imageView];
    
    if (!self.isLocalImage || (self.isLocalImage && self.isGIF)) {
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 3, [UIScreen mainScreen].bounds.size.width, 3)];
        progressView.progressViewStyle = UIProgressViewStyleDefault;
        progressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.2];
        progressView.trackTintColor = [UIColor blackColor];
        [self addSubview:progressView];
        _progressView = progressView;
    }

    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapGesture];
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    self.imageView.frame = rect;
    self.animationInProgress = true;
    [UIView animateWithDuration:0.25 delay:0 options:7 << 16 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
            self.animationInProgress = false;
        }
    }];
}

- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    self.progressView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:7 << 16 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        CGRect toRect = rect;
        toRect.origin.y += self.offsetY;
        // 这一句话用于在放大的时候去关闭
        toRect.origin.x += self.contentOffset.x;
        self.imageView.frame = toRect;
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
    }];
}

#pragma mark - 私有方法

- (void)configWithLocalPictureModel:(id<MFPictureModelProtocol>)pictureModel {
    if (pictureModel.imageType == MFImageTypeGIF) {
        UIImage *animatedImage = pictureModel.animatedImage;
        if (animatedImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:animatedImage.size];
            self.imageView.image = animatedImage;
        }else {
            self.loadingFinished = false;
            self.progressView.alpha = 1;
            [UIView animateWithDuration:1 animations:^{
                [self.progressView setProgress:0.8 animated:true];
            }];
            UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
            [self setPictureSize:image.size];
            self.imageView.image = image;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *imageURL = [[NSBundle mainBundle] URLForResource:pictureModel.imageName withExtension:nil];
                NSData *animatedData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *animatedImage = [UIImage forceDecodedImageWithData:animatedData compressed:pictureModel.compressed];
                self.loadingFinished = true;
                if (animatedImage) {
                    _mf_dispatch_async_on_main_queue(^{
                        pictureModel.animatedImage = animatedImage;
                        pictureModel.posterImage = animatedImage.images.firstObject;
                        [self setPictureSize:animatedImage.size];
                        self.imageView.image = animatedImage;
                        if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                            [_pictureDelegate pictureView:self image:nil animatedImage:animatedImage didLoadAtIndex:self.index];
                        }
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.progressView setProgress:1 animated:true];
                            self.progressView.alpha = 0;
                        }];
                    });
                }else {
                    _mf_dispatch_async_on_main_queue(^{
                        [self.progressView setProgress:1 animated:false];
                        self.progressView.alpha = 0;
                    });
                }
            });
        }
    }else if (pictureModel.imageType == MFImageTypeStaticWebP) {
        UIImage *webpImage = pictureModel.posterImage;
        if (webpImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:webpImage.size];
            self.imageView.image = webpImage;
        }else {
            self.loadingFinished = false;
            self.progressView.alpha = 1;
            [UIView animateWithDuration:1 animations:^{
                [self.progressView setProgress:0.8 animated:true];
            }];
            UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
            [self setPictureSize:image.size];
            self.imageView.image = image;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *imageURL = [[NSBundle mainBundle] URLForResource:pictureModel.imageName withExtension:nil];
                NSData *webpData = [NSData dataWithContentsOfURL:imageURL];
                UIImage *webpImage = [YYImage imageWithData:webpData];
                pictureModel.posterImage = webpImage;
                self.loadingFinished = true;
                if (webpImage) {
                    _mf_dispatch_async_on_main_queue(^{
                        [self setPictureSize:webpImage.size];
                        self.imageView.image = webpImage;
                        if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                            [_pictureDelegate pictureView:self image:webpImage animatedImage:nil didLoadAtIndex:self.index];
                        }
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.progressView setProgress:1 animated:true];
                            self.progressView.alpha = 0;
                        }];
                    });
                }else {
                    _mf_dispatch_async_on_main_queue(^{
                        [self.progressView setProgress:1 animated:false];
                        self.progressView.alpha = 0;
                    });
                }
            });
        }
    }else if (pictureModel.imageType == MFImageTypeAnimatedWebP) {
        YYImage *webpAnimatedImage = pictureModel.webpAnimatedImage;
        if (webpAnimatedImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:webpAnimatedImage.size];
            self.imageView.image = webpAnimatedImage;
        }else {
            self.loadingFinished = false;
            self.progressView.alpha = 1;
            [UIView animateWithDuration:1 animations:^{
                [self.progressView setProgress:0.8 animated:true];
            }];
            UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
            [self setPictureSize:image.size];
            self.imageView.image = image;
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                NSURL *imageURL = [[NSBundle mainBundle] URLForResource:pictureModel.imageName withExtension:nil];
                NSData *webpData = [NSData dataWithContentsOfURL:imageURL];
                YYImage *webpImage = [YYImage imageWithData:webpData];
                pictureModel.webpAnimatedImage = webpImage;
                self.loadingFinished = true;
                if (webpImage) {
                    _mf_dispatch_async_on_main_queue(^{
                        [self setPictureSize:webpImage.size];
                        self.imageView.image = webpImage;
                        if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                            [_pictureDelegate pictureView:self image:webpImage animatedImage:nil didLoadAtIndex:self.index];
                        }
                        [UIView animateWithDuration:0.2 animations:^{
                            [self.progressView setProgress:1 animated:true];
                            self.progressView.alpha = 0;
                        }];
                    });
                }else {
                    _mf_dispatch_async_on_main_queue(^{
                        [self.progressView setProgress:1 animated:false];
                        self.progressView.alpha = 0;
                    });
                }
            });
        }
    }else {
        self.loadingFinished = true;
        self.progressView.alpha = 0;
        UIImage *posterImage = pictureModel.posterImage;
        if (posterImage) {
            [self setPictureSize:posterImage.size];
            self.imageView.image = posterImage;
        }else {
            UIImage *image = [UIImage imageNamed:pictureModel.imageName];
            if (image) {
                pictureModel.posterImage = image;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                    [_pictureDelegate pictureView:self image:image animatedImage:nil didLoadAtIndex:self.index];
                }
            }
        }
    }
}

- (void)configWithRemotePictureModel:(id<MFPictureModelProtocol>)pictureModel {
    if (pictureModel.imageType == MFImageTypeGIF) {
        UIImage *animatedImage = pictureModel.animatedImage;
        if (animatedImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:animatedImage.size];
            self.imageView.image = animatedImage;
        }else {
            NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
            NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
            BOOL imageAvailable = [[YYImageCache sharedCache] containsImageForKey:key];
            if (!imageAvailable) {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                __weak __typeof(self)weakSelf = self;
                self.operation = [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionProgressiveBlur progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _mf_dispatch_async_on_main_queue(^{
                        [strongSelf.progressView setProgress:(1.0 * receivedSize / expectedSize) <= 0.95 ? (1.0 * receivedSize / expectedSize) : 0.95  animated:true];
                    });
                } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (!error && stage == YYWebImageStageFinished) {
                        strongSelf.operation = nil;
                        YYImage *yyImage = (YYImage *)image;
                        NSData *animatedData = yyImage.animatedImageData;
                        UIImage *animatedImage = [UIImage forceDecodedImageWithData:animatedData compressed:pictureModel.compressed];
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            [strongSelf.progressView setProgress:1.f animated:true];
                            strongSelf.progressView.alpha = 0;
                            if (animatedImage) {
                                pictureModel.animatedImage = animatedImage;
                                pictureModel.posterImage = animatedImage.images.firstObject;
                                CGSize size = animatedImage.size;
                                [strongSelf setPictureSize:size];
                                [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                    [strongSelf.imageView animatedTransitionImage:animatedImage];
                                    return true;
                                } withKey:pictureModel.imageURL];
                                
                            }
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:strongSelf image:nil animatedImage:animatedImage didLoadAtIndex:strongSelf.index];
                            }
                        });
                    }else if (error) {
                        strongSelf.operation = nil;
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            strongSelf.progressView.alpha = 0;
                            [strongSelf.progressView setProgress:1.f animated:true];
                        });
                    }
                }];
            }else {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                [UIView animateWithDuration:1 animations:^{
                    [self.progressView setProgress:0.8 animated:true];
                }];
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                [[YYImageCache sharedCache] getImageDataForKey:key withBlock:^(NSData * _Nullable imageData) {
                    UIImage *animatedImage = [UIImage forceDecodedImageWithData:imageData compressed:pictureModel.compressed];
                    self.loadingFinished = true;
                    _mf_dispatch_async_on_main_queue(^{
                        [UIView animateWithDuration:0.2 animations:^{
                            if (animatedImage) {
                                [self.progressView setProgress:1 animated:true];
                            }
                            self.progressView.alpha = 0;
                        }];
                        if (animatedImage) {
                            pictureModel.animatedImage = animatedImage;
                            pictureModel.posterImage = animatedImage.images.firstObject;
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:self image:nil animatedImage:animatedImage didLoadAtIndex:self.index];
                            }
                            CGSize size = animatedImage.size;
                            [self setPictureSize:size];
                            [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                [self.imageView animatedTransitionImage:animatedImage];
                                return true;
                            } withKey:pictureModel.imageURL];
                            
                        }
                    });
                }];
            }
        }
    }else if (pictureModel.imageType == MFImageTypeStaticWebP) {
        UIImage *webpImage = pictureModel.posterImage;
        if (webpImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:webpImage.size];
            self.imageView.image = webpImage;
        }else {
            NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
            NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
            BOOL imageAvailable = [[YYImageCache sharedCache] containsImageForKey:key];
            if (!imageAvailable) {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                __weak __typeof(self)weakSelf = self;
                self.operation = [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionProgressiveBlur progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _mf_dispatch_async_on_main_queue(^{
                        [strongSelf.progressView setProgress:(1.0 * receivedSize / expectedSize) <= 0.95 ? (1.0 * receivedSize / expectedSize) : 0.95  animated:true];
                    });
                } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (!error && stage == YYWebImageStageFinished) {
                        strongSelf.operation = nil;
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            [strongSelf.progressView setProgress:1.f animated:true];
                            strongSelf.progressView.alpha = 0;
                            UIImage *webpImage = (YYImage *)image;
                            if (webpImage) {
                                pictureModel.posterImage = webpImage;
                                CGSize size = webpImage.size;
                                [strongSelf setPictureSize:size];
                                [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                    [strongSelf.imageView animatedTransitionImage:webpImage];
                                    return true;
                                } withKey:pictureModel.imageURL];
                            }
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:strongSelf image:webpImage animatedImage:nil didLoadAtIndex:strongSelf.index];
                            }
                        });
                    }else if (error) {
                        strongSelf.operation = nil;
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            strongSelf.progressView.alpha = 0;
                            [strongSelf.progressView setProgress:1.f animated:true];
                        });
                    }
                }];
            }else {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                [UIView animateWithDuration:1 animations:^{
                    [self.progressView setProgress:0.8 animated:true];
                }];
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                [[YYImageCache sharedCache] getImageDataForKey:key withBlock:^(NSData * _Nullable imageData) {
                    UIImage *webpImage = [YYImage imageWithData:imageData];
                    self.loadingFinished = true;
                    _mf_dispatch_async_on_main_queue(^{
                        [UIView animateWithDuration:0.2 animations:^{
                            if (webpImage) {
                                [self.progressView setProgress:1 animated:true];
                            }
                            self.progressView.alpha = 0;
                        }];
                        if (webpImage) {
                            pictureModel.posterImage = webpImage;
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:self image:webpImage animatedImage:nil didLoadAtIndex:self.index];
                            }
                            CGSize size = webpImage.size;
                            [self setPictureSize:size];
                            [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                [self.imageView animatedTransitionImage:webpImage];
                                return true;
                            } withKey:pictureModel.imageURL];
                        }
                    });
                }];
            }
        }
    }else if (pictureModel.imageType == MFImageTypeAnimatedWebP) {
        UIImage *webpAnimatedImage = pictureModel.webpAnimatedImage;
        if (webpAnimatedImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:webpAnimatedImage.size];
            self.imageView.image = webpAnimatedImage;
        }else {
            NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
            NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
            BOOL imageAvailable = [[YYImageCache sharedCache] containsImageForKey:key];
            if (!imageAvailable) {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                __weak __typeof(self)weakSelf = self;
                self.operation = [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionProgressiveBlur progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _mf_dispatch_async_on_main_queue(^{
                        [strongSelf.progressView setProgress:(1.0 * receivedSize / expectedSize) <= 0.95 ? (1.0 * receivedSize / expectedSize) : 0.95  animated:true];
                    });
                } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    if (!error && stage == YYWebImageStageFinished) {
                        strongSelf.operation = nil;
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            [strongSelf.progressView setProgress:1.f animated:true];
                            strongSelf.progressView.alpha = 0;
                            YYImage *webpImage = (YYImage *)image;
                            if (webpImage) {
                                pictureModel.posterImage = webpImage;
                                pictureModel.webpAnimatedImage = webpImage;
                                CGSize size = webpImage.size;
                                [strongSelf setPictureSize:size];
                                [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                    [strongSelf.imageView animatedTransitionImage:webpImage];
                                    return true;
                                } withKey:pictureModel.imageURL];
                            }
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:strongSelf image:webpImage animatedImage:nil didLoadAtIndex:strongSelf.index];
                            }
                        });
                    }else if (error) {
                        strongSelf.operation = nil;
                        strongSelf.loadingFinished = true;
                        _mf_dispatch_async_on_main_queue(^{
                            strongSelf.progressView.alpha = 0;
                            [strongSelf.progressView setProgress:1.f animated:true];
                        });
                    }
                }];
            }else {
                self.loadingFinished = false;
                self.progressView.alpha = 1;
                [UIView animateWithDuration:1 animations:^{
                    [self.progressView setProgress:0.8 animated:true];
                }];
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                [[YYImageCache sharedCache] getImageDataForKey:key withBlock:^(NSData * _Nullable imageData) {
                    UIImage *webpImage = [YYImage imageWithData:imageData];
                    self.loadingFinished = true;
                    _mf_dispatch_async_on_main_queue(^{
                        [UIView animateWithDuration:0.2 animations:^{
                            if (webpImage) {
                                [self.progressView setProgress:1 animated:true];
                            }
                            self.progressView.alpha = 0;
                        }];
                        if (webpImage) {
                            pictureModel.posterImage = webpImage;
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:self image:webpImage animatedImage:nil didLoadAtIndex:self.index];
                            }
                            CGSize size = webpImage.size;
                            [self setPictureSize:size];
                            [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                [self.imageView animatedTransitionImage:webpImage];
                                return true;
                            } withKey:pictureModel.imageURL];
                        }
                    });
                }];
            }
        }
    }else {
        if (pictureModel.posterImage) {
            self.loadingFinished = true;
            self.progressView.alpha = 0;
            [self setPictureSize:pictureModel.posterImage.size];
            self.imageView.image = pictureModel.posterImage;
        }else {
            NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
            NSString *key = [[YYWebImageManager sharedManager] cacheKeyForURL:url];
            BOOL imageAvailable = [[YYImageCache sharedCache] containsImageForKey:key];
            if (!imageAvailable) {
                self.progressView.alpha = 1;
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                __weak __typeof(self)weakSelf = self;
                self.operation = [[YYWebImageManager sharedManager] requestImageWithURL:url options:YYWebImageOptionProgressiveBlur progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _mf_dispatch_async_on_main_queue(^{
                        [strongSelf.progressView setProgress:(1.0 * receivedSize / expectedSize) <= 0.95 ? (1.0 * receivedSize / expectedSize) : 0.95  animated:true];
                    });
                } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    __strong __typeof(weakSelf)strongSelf = weakSelf;
                    _mf_dispatch_async_on_main_queue(^{
                        if (stage == YYWebImageStageProgress) {
                            strongSelf.progressView.alpha = 1;
                        }else {
                            strongSelf.progressView.alpha = 0;
                        }
                        if (!error && stage == YYWebImageStageFinished) {
                            strongSelf.operation = nil;
                            strongSelf.loadingFinished = true;
                            if (image) {
                                pictureModel.posterImage = image;
                                if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                    [_pictureDelegate pictureView:strongSelf image:image animatedImage:nil didLoadAtIndex:strongSelf.index];
                                }
                                CGSize size = image.size;
                                [strongSelf setPictureSize:size];
                                [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                    [strongSelf.imageView animatedTransitionImage:image];
                                    return true;
                                } withKey:pictureModel.imageURL];
                            }
                        }else if (error){
                            strongSelf.operation = nil;
                            strongSelf.loadingFinished = true;
                        }
                    });
                }];
            }else {
                self.progressView.alpha = 1;
                [UIView animateWithDuration:1 animations:^{
                    [self.progressView setProgress:0.8 animated:true];
                }];
                UIImage *image = pictureModel.posterImage ?: pictureModel.placeholderImage;
                [self setPictureSize:image.size];
                self.imageView.image = image;
                [[YYImageCache sharedCache] getImageDataForKey:key withBlock:^(NSData * _Nullable imageData) {
                    UIImage *image = [UIImage imageWithData:imageData];
                    self.loadingFinished = true;
                    _mf_dispatch_async_on_main_queue(^{
                        [UIView animateWithDuration:0.2 animations:^{
                            if (image) {
                                [self.progressView setProgress:1 animated:true];
                            }
                            self.progressView.alpha = 0;
                        }];
                        if (image) {
                            pictureModel.posterImage = image;
                            if ([_pictureDelegate respondsToSelector:@selector(pictureView:image:animatedImage:didLoadAtIndex:)]) {
                                [_pictureDelegate pictureView:self image:image animatedImage:nil didLoadAtIndex:self.index];
                            }
                            CGSize size = image.size;
                            [self setPictureSize:size];
                            [[MFRunLoopDistribution sharedRunLoopDistribution] addTask:^BOOL{
                                [self.imageView animatedTransitionImage:image];
                                return true;
                            } withKey:pictureModel.imageURL];
                            
                        }
                    });
                }];
            }
        }
    }
}

- (void)setPictureModel:(id<MFPictureModelProtocol>)pictureModel {
    if (!pictureModel) {
        return;
    }
    _pictureModel = pictureModel;
    if (pictureModel.imageName) {
        [self configWithLocalPictureModel:pictureModel];
    }else {
        [self configWithRemotePictureModel:pictureModel];
    }
}

- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.25 delay:0 options:7 << 16  animations:^{
            CGPoint center = self.imageView.center;
            center.x = self.contentSize.width * 0.5;
            self.imageView.center = center;
        } completion:nil];
    }
}

- (void)setLastContentOffset:(CGPoint)lastContentOffset {
    // 如果用户没有在拖动，并且绽放比 > 0.15
    if (!(self.dragging == false && _scale > 0.15)) {
        _lastContentOffset = lastContentOffset;
    }
}

- (void)setPictureSize:(CGSize)pictureSize {
    _pictureSize = pictureSize;
    if (CGSizeEqualToSize(pictureSize, CGSizeZero)) {
        return;
    }
    // 计算实际的大小
    CGFloat screenW = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = screenW / pictureSize.width;
    CGFloat height = scale * pictureSize.height;
    self.showPictureSize = CGSizeMake(screenW, height);
}

- (void)setShowPictureSize:(CGSize)showPictureSize {
    _showPictureSize = showPictureSize;
    self.imageView.frame = [self getImageActualFrame:showPictureSize];
    self.contentSize = self.imageView.frame.size;
}

- (CGRect)getImageActualFrame:(CGSize)imageSize {
    CGFloat x = 0;
    CGFloat y = 0;
    
    if (imageSize.height < [UIScreen mainScreen].bounds.size.height) {
        y = ([UIScreen mainScreen].bounds.size.height - imageSize.height) / 2;
    }
    return CGRectMake(x, y, imageSize.width, imageSize.height);
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - 监听方法

- (void)doubleClick:(UITapGestureRecognizer *)gesture {
    if (!self.isLoadingFinished) {
        return;
    }
    CGFloat newScale = 2;
    if (_doubleClicks) {
        newScale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[gesture locationInView:gesture.view]];
    [self zoomToRect:zoomRect animated:YES];
    _doubleClicks = !_doubleClicks;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
    // 保存 offsetY
    _offsetY = scrollView.contentOffset.y;
    self.progressView.alpha = 0;
    // 正在动画
    if ([self.imageView.layer animationForKey:@"transform"] != nil) {
        return;
    }
    // 用户正在缩放
    if (self.zoomBouncing || self.zooming) {
        return;
    }
    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
    // 滑动到中间
    if (scrollView.contentSize.height > screenH) {
        // 代表没有滑动到底部
        if (_lastContentOffset.y > 0 && _lastContentOffset.y <= scrollView.contentSize.height - screenH) {
            return;
        }
    }
    _scale = fabs(_lastContentOffset.y) / screenH;
    
    // 如果内容高度 > 屏幕高度
    // 并且偏移量 > 内容高度 - 屏幕高度
    // 那么就代表滑动到最底部了
    if (scrollView.contentSize.height > screenH &&
        _lastContentOffset.y > scrollView.contentSize.height - screenH) {
        _scale = (_lastContentOffset.y - (scrollView.contentSize.height - screenH)) / screenH;
    }
    
    // 条件1：拖动到顶部再继续往下拖
    // 条件2：拖动到顶部再继续往上拖
    // 两个条件都满足才去设置 scale -> 针对于长图
    if (scrollView.contentSize.height > screenH) {
        // 长图
        if (scrollView.contentOffset.y < 0 || _lastContentOffset.y > scrollView.contentSize.height - screenH) {
            [_pictureDelegate pictureView:self scale:_scale];
        }
    }else {
        [_pictureDelegate pictureView:self scale:_scale];
    }
    
    // 如果用户松手
    if (scrollView.dragging == false) {
        if (_scale > 0.08 && _scale <= 1) {
            // 关闭
            [_pictureDelegate pictureView:self didClickAtIndex:self.index];
            // 设置 contentOffset
            [scrollView setContentOffset:_lastContentOffset animated:false];
        }else {
            if (!_scale && !self.isLoadingFinished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.progressView.alpha = 1;
                }];
            }
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGPoint center = _imageView.center;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    center.y = scrollView.contentSize.height * 0.5 + offsetY;
    _imageView.center = center;
    if (scrollView.zoomScale == 1 && !self.isLoadingFinished) {
        [UIView animateWithDuration:0.1 animations:^{
            self.progressView.alpha = 1;
        }];
    }
    // 如果是缩小，保证在屏幕中间
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        center.x = scrollView.contentSize.width * 0.5 + offsetX;
        _imageView.center = center;
    }
}

@end
