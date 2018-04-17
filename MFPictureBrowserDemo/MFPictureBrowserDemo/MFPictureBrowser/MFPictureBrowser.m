//
//  MFPictureBrowser.m
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/17.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "MFPictureBrowser.h"
#import "MFPictureView.h"
#import <YYWebImage/YYWebImage.h>
#import <UIView+MFFrame.h>
@interface MFPictureBrowser()
<
UIScrollViewDelegate,
MFPictureViewDelegate
>
/// MFPictureView数组，最多保存9个MFPictureView
@property (nonatomic, strong) NSMutableArray<MFPictureView *> *pictureViews;
/// 图片张数
@property (nonatomic, assign) NSInteger picturesCount;
/// 当前页数
@property (nonatomic, assign) NSInteger currentPage;
/// 界面子控件
@property (nonatomic, weak) UIScrollView *scrollView;
/// 页码文字控件
@property (nonatomic, weak) UILabel *pageTextLabel;
/// 消失的 tap 手势
@property (nonatomic, weak) UITapGestureRecognizer *dismissTapGesture;
/// 结束时, 原来界面 image 所在
@property (nonatomic, strong) UIImageView *endView;
/// 开始时, 原来界面 image 所在
@property (nonatomic, strong) UIImageView *fromView;
@end

@implementation MFPictureBrowser

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
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

- (void)showFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex {
    [self hideStautsBar];
    NSString *errorStr = [NSString stringWithFormat:@"Parameter is not correct, pictureCount is %zd, currentPictureIndex is %zd", picturesCount, currentPictureIndex];
    NSAssert(picturesCount > 0 && currentPictureIndex < picturesCount && picturesCount <= 9, errorStr);
    NSAssert(self.delegate != nil, @"Please set up delegate for pictureBrowser");
    fromView.alpha = 0;
    if (!currentPictureIndex && [_delegate respondsToSelector:@selector(pictureView:imageViewAtIndex:)]) {
        _fromView = [_delegate pictureView:self imageViewAtIndex:currentPictureIndex];
    }
    // 记录值并设置位置
    _currentPage = currentPictureIndex;
    self.picturesCount = picturesCount;
    [self p_setPageText:currentPictureIndex];
    // 添加到 window 上
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    // 计算 scrollView 的 contentSize
    self.scrollView.contentSize = CGSizeMake(picturesCount * _scrollView.width, _scrollView.height);
    // 滚动到指定位置
    [self.scrollView setContentOffset:CGPointMake(currentPictureIndex * _scrollView.width, 0) animated:false];
    // 设置当前展示的MFPictureView的位置以及大小
    for (NSInteger i = 0; i < picturesCount; i++) {
        MFPictureView *pictureView = [self p_setPictureViewForIndex:i fromView: nil];
        [_pictureViews addObject:pictureView];
    }
    MFPictureView *pictureView = _pictureViews[currentPictureIndex];
    // 获取来源图片在屏幕上的位置
    CGRect rect = [fromView convertRect:fromView.bounds toView:nil];

    [pictureView animationShowWithFromRect:rect animationBlock:^{
        self.backgroundColor = [UIColor blackColor];
        if (picturesCount != 1) {
            self.pageTextLabel.alpha = 1;
        }else {
            self.pageTextLabel.alpha = 0;
        }
    } completionBlock:^{
        
    }];
}

- (void)dismiss {
    
    CGFloat x = [UIScreen mainScreen].bounds.size.width * 0.5;
    CGFloat y = [UIScreen mainScreen].bounds.size.height * 0.5;
    CGRect rect = CGRectMake(x, y, 0, 0);
    if ([_delegate respondsToSelector:@selector(pictureView:imageViewAtIndex:)]) {
        _endView = [_delegate pictureView:self imageViewAtIndex:_currentPage];
        if (_endView.superview != nil) {
            rect = [_endView convertRect:_endView.bounds toView:nil];
        }else {
            rect = _endView.frame;
        }
    }
    
    // 取到当前显示的 pictureView
    MFPictureView *pictureView = [[_pictureViews filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"index == %d", _currentPage]] firstObject];
    // 取消所有的下载
    for (MFPictureView *pictureView in _pictureViews) {
        [pictureView.imageView yy_cancelCurrentImageRequest];
    }

    // 执行关闭动画
    [pictureView animationDismissWithToRect:rect animationBlock:^{
        self.backgroundColor = [UIColor clearColor];
        self.pageTextLabel.alpha = 0;
        [self showStatusBar];
    } completionBlock:^{
        [self removeFromSuperview];
        _endView.alpha = 1;
    }];
}


#pragma mark - 手势
- (void)tapGesture:(UITapGestureRecognizer *)gesture {
    [self dismiss];
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([_delegate respondsToSelector:@selector(pictureView:longPressAtIndex:)]) {
            [_delegate pictureView:self longPressAtIndex:_currentPage];
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

#pragma mark - 私有方法

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
    if (_currentPage == currentPage) {
        return;
    }
    _currentPage = currentPage;
    [self p_setPageText:currentPage];
}

/**
 设置pitureView到指定位置
 
 @param index 索引
 @param fromView 从哪个控件显示
 
 @return 当前设置的控件
 */
- (MFPictureView *)p_setPictureViewForIndex:(NSInteger)index fromView:(UIImageView *)fromView {
    MFPictureView *view = [self p_createPictureView];
    view.index = index;
    CGRect frame = view.frame;
    frame.size = self.frame.size;
    view.frame = frame;
    
    // 设置图片的大小<在下载完毕之后会根据下载的图片计算大小>
   
    void(^setImageSizeBlock)(UIImage *) = ^(UIImage *image) {
        if (image != nil) {
            view.pictureSize = image.size;
        }
    };
    
    if ([_delegate respondsToSelector:@selector(pictureView:imageViewAtIndex:)]) {
        UIImageView *v = [_delegate pictureView:self imageViewAtIndex:index];
        UIImage *image = ((UIImageView *)v).image;
        setImageSizeBlock(image);
        // 并且设置占位图片
        view.placeholderImage = image;
    }
    
    NSAssert(([_delegate respondsToSelector:@selector(pictureView:imageURLAtIndex:)] && ![_delegate respondsToSelector:@selector(pictureView:imageNameAtIndex:)]) || (![_delegate respondsToSelector:@selector(pictureView:imageURLAtIndex:)] && [_delegate respondsToSelector:@selector(pictureView:imageNameAtIndex:)]), @"You can not implement both methods!");
    
    if ([_delegate respondsToSelector:@selector(pictureView:imageURLAtIndex:)]) {
        view.imageURL = [_delegate pictureView:self imageURLAtIndex:index];
        view.localImage = false;
    }
    if ([_delegate respondsToSelector:@selector(pictureView:imageNameAtIndex:)]) {
        view.imageName = [_delegate pictureView:self imageNameAtIndex:index];
        view.localImage = true;
    }
    CGPoint center = view.center;
    center.x = index * _scrollView.width + _scrollView.width * 0.5;
    view.center = center;
    return view;
}

- (MFPictureView *)p_createPictureView {
    MFPictureView *view = [[MFPictureView alloc] init];
    [self.dismissTapGesture requireGestureRecognizerToFail:view.imageView.gestureRecognizers.firstObject];
    view.pictureDelegate = self;
    [_scrollView addSubview:view];
//    [_pictureViews addObject:view];
    return view;
}

- (void)p_setPageText:(NSUInteger)index {
    _pageTextLabel.text = [NSString stringWithFormat:@"%zd / %zd", index + 1, self.picturesCount];
    [_pageTextLabel sizeToFit];
    _pageTextLabel.center = self.pageTextCenter;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    _fromView.alpha = 1;
    NSUInteger page = (scrollView.contentOffset.x / scrollView.width + 0.5);
    if ([_delegate respondsToSelector:@selector(pictureView:imageViewAtIndex:)]) {
        _fromView = [_delegate pictureView:self imageViewAtIndex:page];
        _fromView.alpha = 0;
    }
    if (self.currentPage != page) {
        if ([_delegate respondsToSelector:@selector(pictureView:scrollToIndex:)]) {
            [_delegate pictureView:self scrollToIndex:page];
        }
    }
    self.currentPage = page;
}

#pragma mark - MFPictureViewDelegate

- (void)pictureViewTouch:(MFPictureView *)pictureView {
    [self dismiss];
}

- (void)pictureView:(MFPictureView *)pictureView scale:(CGFloat)scale {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1 - scale];
}

- (void)pictureView:(MFPictureView *)pictureView didLoadImageWithError:(NSError *)error {
    if ([_delegate respondsToSelector:@selector(pictureView:didLoadImageAtIndex:withError:)]) {
        [_delegate pictureView:self didLoadImageAtIndex:pictureView.index withError:error];
    }
}

@end
