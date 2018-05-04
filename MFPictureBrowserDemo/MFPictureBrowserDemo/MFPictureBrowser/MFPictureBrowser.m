
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureBrowser.h"
#import "MFPictureView.h"
#import <MFCategory/UIView+MFFrame.h>
#import <YYWebImage/YYWebImage.h>
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
@property (nonatomic, strong) UIImageView *endView;
@property (nonatomic, assign) BOOL animationInProgress;
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
    
    self.animationInProgress = false;
}

#pragma mark - public

- (void)showImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    [self _showFromView:fromView picturesCount:picturesCount currentPictureIndex:currentPictureIndex];
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self _createImagePictureViewAtIndex:i];
        [self.pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = self.pictureViews[currentPictureIndex];
    [self _showPictureView:pictureView fromView:fromView];
}

#pragma mark - private

- (void)_showFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex  {
    NSAssert(picturesCount > 0 && currentPictureIndex < picturesCount && picturesCount <= 9, @"Parameter is not correct");
    NSAssert(self.delegate != nil, @"Please set up delegate for pictureBrowser");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageViewAtIndex:)], @"Please implement delegate method of pictureBrowser:imageViewAtIndex:");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:pictureModelAtIndex:)], @"Please implement delegate method of pictureBrowser:pictureModelAtIndex:");
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

- (MFPictureView *)_createImagePictureViewAtIndex:(NSInteger)index {
    id<MFPictureModelProtocol> pictureModel = [_delegate pictureBrowser:self pictureModelAtIndex:index];
    UIImageView *imageView = [_delegate pictureBrowser:self imageViewAtIndex:index];
    MFPictureView *pictureView = [[MFPictureView alloc] initWithPictureModel:pictureModel];
    [self _configPictureView:pictureView index:index imageView:imageView];
    return pictureView;
}

- (void)_configPictureView:(MFPictureView *)pictureView index:(NSInteger)index imageView:(UIImageView *)imageView {
    [self.dismissTapGesture requireGestureRecognizerToFail:pictureView.imageView.gestureRecognizers.firstObject];
    pictureView.pictureDelegate = self;
    [self.scrollView addSubview:pictureView];
    pictureView.index = index;
    pictureView.size = self.size;
    pictureView.pictureSize = imageView.image.size;
    CGPoint center = pictureView.center;
    center.x = index * _scrollView.width + _scrollView.width * 0.5;
    pictureView.center = center;
}

- (void)_showPictureView:(MFPictureView *)pictureView fromView:(UIImageView *)fromView{
    [self _hideStautsBar];
    CGRect rect = [fromView convertRect:fromView.bounds toView:nil];
    [pictureView animationShowWithFromRect:rect animationBlock:^{
        self.backgroundColor = [UIColor blackColor];
        if (self.picturesCount != 1) {
            self.pageTextLabel.alpha = 1;
        }else {
            self.pageTextLabel.alpha = 0;
        }
    } completionBlock:^{}];
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
    // 取消未完成请求
    for (MFPictureView *pictureView in self.pictureViews) {
        if (pictureView.operation) {
            [pictureView.operation cancel];
        }
    }
    // 取到当前显示的 pictureView
    MFPictureView *pictureView = [[_pictureViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index == %d", self.currentIndex]] firstObject];
    
    // 执行关闭动画
    [pictureView animationDismissWithToRect:rect animationBlock:^{
        self.backgroundColor = [UIColor clearColor];
        self.pageTextLabel.alpha = 0;
        [self _showStatusBar];
    } completionBlock:^{
        [self removeFromSuperview];
        [self.pictureViews removeAllObjects];
        if ([_delegate respondsToSelector:@selector(pictureBrowser:dimissAtIndex:)] && !self.animationInProgress) {
            [_delegate pictureBrowser:self dimissAtIndex:self.currentIndex];
        }
        self.animationInProgress = true;
    }];
}


#pragma mark - gesture
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
- (void)_hideStautsBar {
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    [UIView animateWithDuration:0.15 animations:^{
        statusBar.transform = CGAffineTransformMakeTranslation(0, -statusBar.height);
    }];
}

- (void)_showStatusBar {
    UIView *statusBar = [[UIApplication sharedApplication] valueForKey:@"statusBar"];
    [UIView animateWithDuration:0.15 animations:^{
        statusBar.transform = CGAffineTransformIdentity;
    }];
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
    [self _setPageText:currentIndex];
}

- (void)_setPageText:(NSUInteger)index {
    _pageTextLabel.text = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.picturesCount];
    [_pageTextLabel sizeToFit];
    _pageTextLabel.center = self.pageTextCenter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger index = (scrollView.contentOffset.x / scrollView.width + 0.5);
    if (self.currentIndex != index) {
        if ([_delegate respondsToSelector:@selector(pictureBrowser:scrollToIndex:)]) {
            [_delegate pictureBrowser:self scrollToIndex:index];
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

- (void)pictureView:(MFPictureView *)pictureView image:(UIImage *)image animatedImage:(UIImage *)animatedImage didLoadAtIndex:(NSInteger)index {
    if ([_delegate respondsToSelector:@selector(pictureBrowser:image:animatedImage:didLoadAtIndex:)]) {
        [_delegate pictureBrowser:self image:image animatedImage:animatedImage didLoadAtIndex:index];
    }
}

@end
