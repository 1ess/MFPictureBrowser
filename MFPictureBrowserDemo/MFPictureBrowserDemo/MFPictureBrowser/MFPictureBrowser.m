
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureBrowser.h"
#import "MFPictureView.h"
#import <MFCategory/UIView+MFFrame.h>
@interface MFPictureBrowser()
<
UIScrollViewDelegate,
MFPictureViewDelegate
>
/// MFPictureView数组，最多保存9个MFPictureView
@property (nonatomic, strong) NSMutableArray<MFPictureView *> *pictureViews;
@property (nonatomic, assign) NSInteger picturesCount;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UILabel *pageTextLabel;
@property (nonatomic, weak) UITapGestureRecognizer *dismissTapGesture;
@property (nonatomic, strong) FLAnimatedImageView *endView;
@property (nonatomic, strong) FLAnimatedImageView *fromView;
@property (nonatomic, assign) BOOL localImage;
@end

@implementation MFPictureBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        [self configuration];
    }
    return self;
}

- (void)configuration {
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    // 设置默认属性
    self.imagesSpacing = 20;
    self.pageTextFont = [UIFont systemFontOfSize:16];
    self.pageTextCenter = CGPointMake(self.width * 0.5, self.height - 20);
    self.pageTextColor = [UIColor whiteColor];
    // 初始化数组
    self.pictureViews = @[].mutableCopy;
    // 初始化 scrollView
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(- self.imagesSpacing * 0.5, 0, self.width + self.imagesSpacing, self.height)];
    scrollView.showsVerticalScrollIndicator = false;
    scrollView.showsHorizontalScrollIndicator = false;
    scrollView.pagingEnabled = true;
    scrollView.delegate = self;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
    
    // 初始化label
    UILabel *label = [[UILabel alloc] init];
    label.alpha = 0;
    label.textColor = self.pageTextColor;
    label.center = self.pageTextCenter;
    label.font = self.pageTextFont;
    [self addSubview:label];
    self.pageTextLabel = label;
    
    // 添加手势事件
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
    [self addGestureRecognizer:longPressGesture];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [self addGestureRecognizer:tapGesture];
    self.dismissTapGesture = tapGesture;
}

#pragma mark - 公共方法
- (void)showLocalImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    self.localImage = true;
    [self showFromView:fromView picturesCount:picturesCount currentPictureIndex:currentPictureIndex];
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self createLocalImagePictureViewAtIndex:i];
        if (i != currentPictureIndex) {
            [pictureView.imageView stopAnimating];
        }else {
            [pictureView.imageView startAnimating];
        }
        [_pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = self.pictureViews[currentPictureIndex];
    [self showPictureView:pictureView fromView:fromView];
}

- (void)showNetworkImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    self.localImage = false;
    [self showFromView:fromView picturesCount:picturesCount currentPictureIndex:currentPictureIndex];
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self createNetworkImagePictureViewAtIndex:i];
        if (i != currentPictureIndex) {
            [pictureView.imageView stopAnimating];
        }else {
            [pictureView.imageView startAnimating];
        }
        [_pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = self.pictureViews[currentPictureIndex];
    [self showPictureView:pictureView fromView:fromView];
    
}

#pragma mark - 私有方法
- (MFPictureView *)createLocalImagePictureViewAtIndex:(NSInteger)index{
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)], @"Please implement delegate method of pictureBrowser:imageNameAtIndex:");
    NSAssert(![_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)], @"Please DO NOT implement delegate method of pictureBrowser:imageURLAtIndex:");
    NSString *imageName = [_delegate pictureBrowser:self imageNameAtIndex:index];
    FLAnimatedImageView *imageView = [_delegate pictureBrowser:self imageViewAtIndex:index];
    MFPictureView *view = [[MFPictureView alloc] initWithImageName:imageName decodedAnimatedImage:imageView.animatedImage];
    [self configPictureView:view index:index animtedImageView:imageView];
    return view;
}

- (MFPictureView *)createNetworkImagePictureViewAtIndex:(NSInteger)index {
    NSAssert(![_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)], @"Please DO NOT implement delegate method of pictureBrowser:imageNameAtIndex:");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)], @"Please implement delegate method of pictureBrowser:imageURLAtIndex:");
    NSString *imageURL = [_delegate pictureBrowser:self imageURLAtIndex:index];
    FLAnimatedImageView *imageView = [_delegate pictureBrowser:self imageViewAtIndex:index];
    MFPictureView *view = [[MFPictureView alloc] initWithImageURL:imageURL decodedAnimatedImage:imageView.animatedImage];
    [self configPictureView:view index:index animtedImageView:imageView];
    return view;
}

- (void)configPictureView:(MFPictureView *)pictureView index:(NSInteger)index animtedImageView:(FLAnimatedImageView *)animtedImageView {
    [self.dismissTapGesture requireGestureRecognizerToFail:pictureView.imageView.gestureRecognizers.firstObject];
    pictureView.pictureDelegate = self;
    [self.scrollView addSubview:pictureView];
    pictureView.index = index;
    pictureView.size = self.size;
    if (animtedImageView.image) {
        pictureView.pictureSize = animtedImageView.image.size;
    }else if (animtedImageView.animatedImage) {
        pictureView.pictureSize = animtedImageView.animatedImage.size;
    }
    CGPoint center = pictureView.center;
    center.x = index * _scrollView.width + _scrollView.width * 0.5;
    pictureView.center = center;
}

- (void)showFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex  {
    [self hideStautsBar];
    NSAssert(picturesCount > 0 && currentPictureIndex < picturesCount && picturesCount <= 9, @"Parameter is not correct");
    NSAssert(self.delegate != nil, @"Please set up delegate for pictureBrowser");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageViewAtIndex:)], @"Please implement delegate method of pictureBrowser:imageViewAtIndex:");
    if (self.localImage) {
        self.fromView = [_delegate pictureBrowser:self imageViewAtIndex:currentPictureIndex];
        self.fromView.alpha = 0;
    }
    // 记录值并设置位置
    self.picturesCount = picturesCount;
    self.currentIndex = currentPictureIndex;
    // 添加到 window 上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 计算 scrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(picturesCount * _scrollView.width, _scrollView.height);
    // 滚动到指定位置
    [self.scrollView setContentOffset:CGPointMake(currentPictureIndex * _scrollView.width, 0) animated:false];
}

- (void)showPictureView:(MFPictureView *)pictureView fromView:(UIImageView *)fromView{
    CGRect rect = [fromView convertRect:fromView.bounds toView:nil];
    [pictureView animationShowWithFromRect:rect animationBlock:^{
        self.backgroundColor = [UIColor blackColor];
        if (self.picturesCount != 1) {
            self.pageTextLabel.alpha = 1;
        }else {
            self.pageTextLabel.alpha = 0;
        }
    } completionBlock:nil];
}

- (void)dismiss {
    CGFloat x = [UIScreen mainScreen].bounds.size.width * 0.5;
    CGFloat y = [UIScreen mainScreen].bounds.size.height * 0.5;
    CGRect rect = CGRectMake(x, y, 0, 0);
    self.endView = [_delegate pictureBrowser:self imageViewAtIndex:self.currentIndex];
    if (self.endView.superview != nil) {
        rect = [_endView convertRect:_endView.bounds toView:nil];
    }else {
        rect = _endView.frame;
    }
    // 取到当前显示的 pictureView
    MFPictureView *pictureView = [[_pictureViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index == %d", self.currentIndex]] firstObject];
    // 取消所有的下载
//    for (MFPictureView *pictureView in _pictureViews) {
//        [pictureView.imageView yy_cancelCurrentImageRequest];
//    }

    // 执行关闭动画
    __weak __typeof(self)weakSelf = self;
    [pictureView animationDismissWithToRect:rect animationBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.backgroundColor = [UIColor clearColor];
        strongSelf.pageTextLabel.alpha = 0;
        [strongSelf showStatusBar];
    } completionBlock:^{
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf removeFromSuperview];
        [strongSelf.pictureViews removeAllObjects];
        if (strongSelf.localImage) {
            strongSelf.endView.alpha = 1;
        }
        if ([_delegate respondsToSelector:@selector(pictureBrowser:dimissAtIndex:)]) {
            [_delegate pictureBrowser:strongSelf dimissAtIndex:strongSelf.currentIndex];
        }
    }];
}


#pragma mark - 手势
- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    [self dismiss];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([_delegate respondsToSelector:@selector(pictureBrowser:longPressAtIndex:)]) {
            [_delegate pictureBrowser:self longPressAtIndex:self.currentIndex];
        }
    }
}

#pragma mark - 状态栏状态
- (void)hideStautsBar {
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 0;
}

- (void)showStatusBar {
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    statusBar.alpha = 1;
}

- (void)setPageTextFont:(UIFont *)pageTextFont {
    _pageTextFont = pageTextFont;
    self.pageTextLabel.font = pageTextFont;
}

- (void)setPageTextColor:(UIColor *)pageTextColor {
    _pageTextColor = pageTextColor;
    self.pageTextLabel.textColor = pageTextColor;
}

- (void)setPageTextCenter:(CGPoint)pageTextCenter {
    _pageTextCenter = pageTextCenter;
    [self.pageTextLabel sizeToFit];
    self.pageTextLabel.center = pageTextCenter;
}

- (void)setImagesSpacing:(CGFloat)imagesSpacing {
    _imagesSpacing = imagesSpacing;
    self.scrollView.frame = CGRectMake(- _imagesSpacing * 0.5, 0, self.width + _imagesSpacing, self.height);
}

- (void)setCurrentIndex:(NSInteger)currentIndex {
    _currentIndex = currentIndex;
    [self p_setPageText:currentIndex];
}

- (void)p_setPageText:(NSUInteger)index {
    _pageTextLabel.text = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.picturesCount];
    [_pageTextLabel sizeToFit];
    _pageTextLabel.center = self.pageTextCenter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger index = (scrollView.contentOffset.x / scrollView.width + 0.5);
    if (self.currentIndex != index) {
        MFPictureView *view = self.pictureViews[self.currentIndex];
        if (view.imageView.animatedImage) {
            [view.imageView stopAnimating];
        }
        MFPictureView *currentView = self.pictureViews[index];
        if (currentView.imageView.animatedImage) {
            [currentView.imageView startAnimating];
        }
        if (self.localImage) {
            self.fromView.alpha = 1;
        }
        if ([_delegate respondsToSelector:@selector(pictureBrowser:scrollToIndex:)]) {
            [_delegate pictureBrowser:self scrollToIndex:index];
        }
        if (self.localImage) {
            self.fromView = [_delegate pictureBrowser:self imageViewAtIndex:index];
            self.fromView.alpha = 0;
        }
        self.currentIndex = index;
    }
}

#pragma mark - MFPictureViewDelegate

- (void)pictureView:(MFPictureView *)pictureView didClickAtIndex:(NSInteger)index{
    [self dismiss];
}

- (void)pictureView:(MFPictureView *)pictureView scale:(CGFloat)scale {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - scale];
}

- (void)pictureView:(MFPictureView *)pictureView image:(UIImage *)image animatedImage:(FLAnimatedImage *)animatedImage didLoadAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pictureBrowser:image:animatedImage:didLoadAtIndex:)]) {
        [_delegate pictureBrowser:self image:image animatedImage:animatedImage didLoadAtIndex:index];
    }
}

@end
