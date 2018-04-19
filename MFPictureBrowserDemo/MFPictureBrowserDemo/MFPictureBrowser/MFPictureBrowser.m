
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import "MFPictureBrowser.h"
#import "MFPictureView.h"
#import <YYWebImage/YYWebImage.h>
#import <MFCategory/UIView+MFFrame.h>
@interface MFPictureBrowser()
<
UIScrollViewDelegate,
MFPictureViewDelegate
>
/// MFPictureView数组，最多保存9个MFPictureView
@property (nonatomic, strong) NSMutableArray<MFPictureView *> *pictureViews;
@property (nonatomic, assign) NSInteger picturesCount;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UILabel *pageTextLabel;
@property (nonatomic, weak) UITapGestureRecognizer *dismissTapGesture;
@property (nonatomic, strong) UIImageView *endView;
@property (nonatomic, strong) UIImageView *fromView;
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

- (MFPictureView *)createLocalImagePictureViewAtIndex:(NSInteger)index fromView:(UIImageView *)fromView {
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)], @"Please implement delegate method of pictureBrowser:imageNameAtIndex:");
    NSAssert(![_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)], @"Please DO NOT implement delegate method of pictureBrowser:imageURLAtIndex:");
    NSString *imageName = [_delegate pictureBrowser:self imageNameAtIndex:index];
    MFPictureView *view = [[MFPictureView alloc] initWithImageName:imageName];
    [self.dismissTapGesture requireGestureRecognizerToFail:view.imageView.gestureRecognizers.firstObject];
    view.pictureDelegate = self;
    [self.scrollView addSubview:view];
    view.index = index;
    view.size = self.size;
    
    UIImageView *v = [_delegate pictureBrowser:self imageViewAtIndex:index];
    if (v.image) {
        view.pictureSize = v.image.size;
    }
    // 并且设置占位图片
    view.placeholderImage = v.image;
    CGPoint center = view.center;
    center.x = index * _scrollView.width + _scrollView.width * 0.5;
    view.center = center;
    return view;
}

- (MFPictureView *)createNetworkImagePictureViewAtIndex:(NSInteger)index fromView:(UIImageView *)fromView {
    NSAssert(![_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)], @"Please DO NOT implement delegate method of pictureBrowser:imageNameAtIndex:");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)], @"Please implement delegate method of pictureBrowser:imageURLAtIndex:");
    return nil;
}


//- (MFPictureView *)p_createPictureViewAtIndex:(NSInteger)index fromView:(UIImageView *)fromView {
//    MFPictureView *view = [[MFPictureView alloc] init];
//    [self.dismissTapGesture requireGestureRecognizerToFail:view.imageView.gestureRecognizers.firstObject];
//    view.pictureDelegate = self;
//    [self.scrollView addSubview:view];
//    view.index = index;
////    view.size = self.size;
//    CGRect frame = view.frame;
//    frame.size = self.frame.size;
//    view.frame = frame;
//    
//    // 设置图片的大小<在下载完毕之后会根据下载的图片计算大小>
//    
//    if ([_delegate respondsToSelector:@selector(pictureBrowser:imageViewAtIndex:)]) {
//        UIImageView *v = [_delegate pictureBrowser:self imageViewAtIndex:index];
//        UIImage *image = ((UIImageView *)v).image;
//        if (image != nil) {
//            view.pictureSize = image.size;
//        }
//        // 并且设置占位图片
//        view.placeholderImage = image;
//    }
//    
//    NSAssert(([_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)] && ![_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)]) || (![_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)] && [_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)]), @"You can not implement both methods!");
//    
//    if ([_delegate respondsToSelector:@selector(pictureBrowser:imageURLAtIndex:)]) {
//        view.imageURL = [_delegate pictureBrowser:self imageURLAtIndex:index];
//        view.localImage = false;
//    }
//    if ([_delegate respondsToSelector:@selector(pictureBrowser:imageNameAtIndex:)]) {
//        view.imageName = [_delegate pictureBrowser:self imageNameAtIndex:index];
//        view.localImage = true;
//    }
//    CGPoint center = view.center;
//    center.x = index * _scrollView.width + _scrollView.width * 0.5;
//    view.center = center;
//    return view;
//}

- (void)showLocalImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    [self showFromView:fromView picturesCount:picturesCount currentPictureIndex:currentPictureIndex];
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self createLocalImagePictureViewAtIndex:i fromView:nil];
        [_pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = self.pictureViews[currentPictureIndex];
    [self showPictureView:pictureView fromView:fromView];
}

- (void)showNetworkImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    [self showFromView:fromView picturesCount:picturesCount currentPictureIndex:currentPictureIndex];
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self createNetworkImagePictureViewAtIndex:i fromView:nil];
        [_pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = self.pictureViews[currentPictureIndex];
    [self showPictureView:pictureView fromView:fromView];
    
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

- (void)showFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    [self hideStautsBar];
    NSAssert(picturesCount > 0 && currentPictureIndex < picturesCount && picturesCount <= 9, @"Parameter is not correct");
    NSAssert(self.delegate != nil, @"Please set up delegate for pictureBrowser");
    NSAssert([_delegate respondsToSelector:@selector(pictureBrowser:imageViewAtIndex:)], @"Please implement delegate method of pictureBrowser:imageViewAtIndex:");
    self.fromView = [_delegate pictureBrowser:self imageViewAtIndex:currentPictureIndex];
    self.fromView.alpha = 0;
    // 记录值并设置位置
    self.picturesCount = picturesCount;
    self.currentPage = currentPictureIndex;
    // 添加到 window 上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 计算 scrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(picturesCount * _scrollView.width, _scrollView.height);
    // 滚动到指定位置
    [self.scrollView setContentOffset:CGPointMake(currentPictureIndex * _scrollView.width, 0) animated:false];
}

- (void)dismiss {
    
    CGFloat x = [UIScreen mainScreen].bounds.size.width * 0.5;
    CGFloat y = [UIScreen mainScreen].bounds.size.height * 0.5;
    CGRect rect = CGRectMake(x, y, 0, 0);
    self.endView = [_delegate pictureBrowser:self imageViewAtIndex:_currentPage];
    if (self.endView.superview != nil) {
        rect = [_endView convertRect:_endView.bounds toView:nil];
    }else {
        rect = _endView.frame;
    }
    
    // 取到当前显示的 pictureView
    MFPictureView *pictureView = [[_pictureViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index == %d", _currentPage]] firstObject];
    // 取消所有的下载
    for (MFPictureView *pictureView in _pictureViews) {
        [pictureView.imageView yy_cancelCurrentImageRequest];
    }

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
        strongSelf.endView.alpha = 1;
    }];
}


#pragma mark - 手势
- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    [self dismiss];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([_delegate respondsToSelector:@selector(pictureBrowser:longPressAtIndex:)]) {
            [_delegate pictureBrowser:self longPressAtIndex:self.currentPage];
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

- (void)setCurrentPage:(NSInteger)currentPage {
    _currentPage = currentPage;
    [self p_setPageText:currentPage];
}

- (void)p_setPageText:(NSUInteger)index {
    _pageTextLabel.text = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.picturesCount];
    [_pageTextLabel sizeToFit];
    _pageTextLabel.center = self.pageTextCenter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSUInteger page = (scrollView.contentOffset.x / scrollView.width + 0.5);
    if (self.currentPage != page) {
        self.fromView.alpha = 1;
        if ([_delegate respondsToSelector:@selector(pictureBrowser:scrollToIndex:)]) {
            [_delegate pictureBrowser:self scrollToIndex:page];
        }
        self.fromView = [_delegate pictureBrowser:self imageViewAtIndex:page];
        self.fromView.alpha = 0;
        self.currentPage = page;
    }
    
}

#pragma mark - MFPictureViewDelegate

- (void)pictureView:(MFPictureView *)pictureView didClickAtIndex:(NSInteger)index{
    [self dismiss];
}

- (void)pictureView:(MFPictureView *)pictureView scale:(CGFloat)scale {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - scale];
}

- (void)pictureView:(MFPictureView *)pictureView imageDidLoadAtIndex:(NSInteger)index withError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(pictureBrowser:imageDidLoadAtIndex:withError:)]) {
        [_delegate pictureBrowser:self imageDidLoadAtIndex:index withError:error];
    }
}

@end
