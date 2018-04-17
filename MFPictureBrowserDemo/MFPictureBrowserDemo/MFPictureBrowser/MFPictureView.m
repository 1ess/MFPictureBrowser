//
//  MFPictureView.m
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/17.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "MFPictureView.h"

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
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign) BOOL loadingFinished;
@end

@implementation MFPictureView

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
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
    YYAnimatedImageView *imageView = [[YYAnimatedImageView alloc] init];
    imageView.clipsToBounds = true;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.frame = self.bounds;
    imageView.userInteractionEnabled = true;
    _imageView = imageView;
    [self addSubview:imageView];
    
    if (!self.localImage) {
        self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height - 3, [UIScreen mainScreen].bounds.size.width, 3)];
        self.progressView.progressViewStyle = UIProgressViewStyleDefault;
        self.progressView.tintColor = [UIColor colorWithWhite:1 alpha:0.6];
        self.progressView.trackTintColor = [UIColor colorWithWhite:0 alpha:0.2];
        [self addSubview:self.progressView];
        self.progressView.alpha = 0;
        CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 3.0f);
        self.progressView.transform = transform;
    }
    
    // 添加监听事件
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleClick:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [imageView addGestureRecognizer:doubleTapGesture];
}

- (void)setShowingAnimation:(BOOL)showingAnimation {
    _showingAnimation = showingAnimation;
    if (showingAnimation) {
        self.progressView.alpha = 0;
    }else {
        self.progressView.alpha = self.progressView.progress == 1;
    }
}

#pragma mark - 外部方法

- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    _imageView.frame = rect;
    
    self.showingAnimation = true;
    [UIView animateWithDuration:0.25 animations:^{
        if (animationBlock != nil) {
            animationBlock();
        }
        self.imageView.frame = [self getImageActualFrame:self.showPictureSize];
    } completion:^(BOOL finished) {
        if (finished) {
            if (completionBlock) {
                completionBlock();
            }
        }
        self.showingAnimation = false;
    }];
}

- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void (^)(void))animationBlock completionBlock:(void (^)(void))completionBlock {
    // 隐藏进度视图
    self.progressView.alpha = 0;;
    [UIView animateWithDuration:0.25 animations:^{
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

- (void)layoutSubviews {
    [super layoutSubviews];
}


- (void)setImageName:(NSString *)imageName {
    if (!imageName) {
        return;
    }
    _imageName = imageName;
    self.userInteractionEnabled = true;
    YYImage *image = [YYImage imageNamed:imageName];
    [self setPictureSize:image.size];
    self.imageView.image = image;
}

- (void)setImageURL:(NSString *)imageURL {
    if (!imageURL) {
        return;
    }
    _imageURL = imageURL;
    YYWebImageManager *manager = [YYWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:imageURL]];
    NSData *data = [manager.cache getImageDataForKey:key];
    // 如果没有在执行动画，那么就显示出来
    if (!data && !self.showingAnimation) {
        self.progressView.alpha = 1;
    }else {
        self.progressView.alpha = 0;
    }
    // 取消上一次的下载
    self.userInteractionEnabled = false;
    [self.imageView yy_setImageWithURL:[NSURL URLWithString:imageURL] placeholder:self.placeholderImage options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        CGFloat progress = 1.0 * receivedSize / expectedSize ;
        [self.progressView setProgress:progress animated:true];
    } transform:nil completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        self.loadingFinished = true;
        if (error) {
            self.progressView.alpha = 0;
        }else {
            if (stage == YYWebImageStageFinished) {
                self.progressView.alpha = 0;
                self.userInteractionEnabled = true;
                if ([_pictureDelegate respondsToSelector:@selector(pictureView:didLoadImageWithError:)]) {
                    [_pictureDelegate pictureView:self didLoadImageWithError:error];
                }
                if (image) {
                    // 计算图片的大小
                    [self setPictureSize:image.size];
                }else {
                    self.progressView.progress = 1;
                }
            }
        }
    }];
}


- (void)setContentSize:(CGSize)contentSize {
    [super setContentSize:contentSize];
    if (self.zoomScale == 1) {
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint center = self.imageView.center;
            center.x = self.contentSize.width * 0.5;
            self.imageView.center = center;
        }];
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
    self.imageView.frame = [self getImageActualFrame:_showPictureSize];
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

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center{
    CGRect zoomRect;
    zoomRect.size.height =self.frame.size.height / scale;
    zoomRect.size.width  =self.frame.size.width  / scale;
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

#pragma mark - 监听方法

- (void)doubleClick:(UITapGestureRecognizer *)ges {
    if (!self.loadingFinished) {
        return;
    }
    CGFloat newScale = 2;
    if (_doubleClicks) {
        newScale = 1;
    }
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:[ges locationInView:ges.view]];
    [self zoomToRect:zoomRect animated:YES];
    _doubleClicks = !_doubleClicks;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    self.lastContentOffset = scrollView.contentOffset;
    // 保存 offsetY
    _offsetY = scrollView.contentOffset.y;
    
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
        if (_scale > 0.15 && _scale <= 1) {
            // 关闭
            [_pictureDelegate pictureViewTouch:self];
            // 设置 contentOffset
            [scrollView setContentOffset:_lastContentOffset animated:false];
        }
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    CGPoint center = _imageView.center;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    center.y = scrollView.contentSize.height * 0.5 + offsetY;
    _imageView.center = center;
    
    // 如果是缩小，保证在屏幕中间
    if (scrollView.zoomScale < scrollView.minimumZoomScale) {
        CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
        center.x = scrollView.contentSize.width * 0.5 + offsetX;
        _imageView.center = center;
    }
}

@end
