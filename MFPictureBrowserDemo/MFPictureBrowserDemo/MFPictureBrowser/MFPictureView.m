
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureView.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import <PINCache/PINCache.h>
@interface MFPictureView()
<
UIScrollViewDelegate
>
@property (nonatomic, assign) CGSize showPictureSize;
@property (nonatomic, assign) BOOL doubleClicks;
@property (nonatomic, assign) CGPoint lastContentOffset;
@property (nonatomic, assign) CGFloat scale;
@property (nonatomic, assign) CGFloat offsetY;
@property (nonatomic, assign, getter = isShowingAnimation) BOOL showingAnimation;

@property (nonatomic, assign) BOOL loadingFinished;
@property (nonatomic, assign, getter = isLocalImage) BOOL localImage;
@property (nonatomic, strong) UIProgressView *progressView;
@end

@implementation MFPictureView

- (instancetype)initWithImageName:(NSString *)imageName {
    self = [super init];
    if (self) {
        self.localImage = true;
        [self setupUI];
        self.imageName = imageName;
        self.imageURL = nil;
        self.placeholderImage = nil;
    }
    return self;
}
- (instancetype)initWithImageURL:(NSString *)imageURL placeholderImage:(UIImage *)placeholderImage {
    self = [super init];
    if (self) {
        self.localImage = false;
        [self setupUI];
        self.imageName = nil;
        self.placeholderImage = placeholderImage;
        self.imageURL = imageURL;
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

    // 添加 imageView
    FLAnimatedImageView *imageView = [[FLAnimatedImageView alloc] init];
    imageView.clipsToBounds = true;
    imageView.layer.cornerRadius = 3;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = true;
    _imageView = imageView;
    [self addSubview:imageView];
    
    if (!self.isLocalImage) {
        //进度条
        UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 3, [UIScreen mainScreen].bounds.size.width, 3)];
        progressView.progressViewStyle = UIProgressViewStyleDefault;
        progressView.progressTintColor = [UIColor colorWithWhite:1 alpha:0.2];
        progressView.trackTintColor = [UIColor blackColor];
        [self addSubview:progressView];
        _progressView = progressView;
    }
    
    // 添加监听事件
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapGesture];
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    self.imageView.frame = rect;
    self.showingAnimation = true;
    [UIView animateWithDuration:0.25 delay:0 options:7 << 16 animations:^{
        if (animationBlock) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    } completion:^(BOOL finished) {
        if (finished && completionBlock) {
            self.showingAnimation = false;
            completionBlock();
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
        if (finished && completionBlock) {
            completionBlock();
        }
    }];
}

#pragma mark - 私有方法

- (void)setImageName:(NSString *)imageName {
    if (!imageName) {
        return;
    }
    _imageName = imageName;
    self.userInteractionEnabled = true;
    self.loadingFinished = true;
    
    if ([imageName.pathExtension isEqualToString:@"gif"] || [imageName.pathExtension isEqualToString:@"webp"]) {
        NSURL *imageUrl = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
        FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imageUrl]];
        [self setPictureSize:animatedImage.size];
        self.imageView.animatedImage = animatedImage;
    }else {
        UIImage *image = [UIImage imageNamed:imageName];
        [self setPictureSize:image.size];
        self.imageView.image = image;
    }
    
    
}

- (void)setImageURL:(NSString *)imageURL {
    if (!imageURL) {
        return;
    }
    _imageURL = imageURL;
    NSString *cacheKey = [[PINRemoteImageManager sharedImageManager] cacheKeyForURL:[NSURL URLWithString:imageURL] processorKey:nil];
    PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
    BOOL imageAvailable = [cache containsObjectForKey:cacheKey];
    
    self.userInteractionEnabled = true;
    self.progressView.alpha = 1;
    [self.imageView setPin_updateWithProgress:YES];
    __weak __typeof(self)weakSelf = self;
    [self.imageView pin_setImageFromURL:[NSURL URLWithString:imageURL] placeholderImage:self.placeholderImage completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result.resultType == PINRemoteImageResultTypeProgress) {
                strongSelf.progressView.alpha = 1;
            }else {
                strongSelf.progressView.alpha = 0;
            }
        });
        if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
            strongSelf.loadingFinished = true;
            strongSelf.userInteractionEnabled = true;
            if (!imageAvailable) {
                if ([_pictureDelegate respondsToSelector:@selector(pictureView:imageDidLoadAtIndex:image:animatedImage:error:)]) {
                    [_pictureDelegate pictureView:strongSelf imageDidLoadAtIndex:strongSelf.index image:result.image animatedImage:result.animatedImage error:result.error];
                }
            }
            if (result.image) {
                // 计算图片的大小
                [strongSelf setPictureSize:result.image.size];
            }else if (result.animatedImage) {
                [strongSelf setPictureSize:result.animatedImage.size];
            }
        }
    }];
    
    if (!imageAvailable) {
        [[PINRemoteImageManager sharedImageManager] downloadImageWithURL:[NSURL URLWithString:imageURL] options:(PINRemoteImageManagerDownloadOptionsNone) progressDownload:^(int64_t completedBytes, int64_t totalBytes) {
            CGFloat progress = 1.0 * completedBytes / totalBytes ;
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                //更新进度
                [strongSelf.progressView setProgress:progress animated:true];
            });
        } completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        }];
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
    if (!self.loadingFinished) {
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
            if (!_scale && !self.loadingFinished) {
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
    if (scrollView.zoomScale == 1 && !self.loadingFinished) {
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
