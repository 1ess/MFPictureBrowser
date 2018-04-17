
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
@class MFPictureView;
@protocol MFPictureViewDelegate <NSObject>
- (void)pictureViewTouch:(MFPictureView *)pictureView;
- (void)pictureView:(MFPictureView *)pictureView scale:(CGFloat)scale;
- (void)pictureView:(MFPictureView *)pictureView didLoadImageWithError:(NSError *)error;
@end

@interface MFPictureView : UIScrollView
// 当前视图所在的索引
@property (nonatomic, assign) NSInteger index;
// 图片的大小
@property (nonatomic, assign) CGSize pictureSize;
// 显示的默认图片
@property (nonatomic, strong) UIImage *placeholderImage;
// 图片的地址 URL
@property (nonatomic, strong) NSString *imageURL;
// 本地图片名
@property (nonatomic, strong) NSString *imageName;
// 本地图片?
@property (nonatomic, assign) BOOL localImage;
// 当前显示图片的控件
@property (nonatomic, strong, readonly) YYAnimatedImageView *imageView;
// 代理
@property (nonatomic, weak) id<MFPictureViewDelegate> pictureDelegate;

/**
 动画显示
 
 @param rect            从哪个位置开始做动画
 @param animationBlock  附带的动画信息
 @param completionBlock 结束的回调
 */
- (void)animationShowWithFromRect:(CGRect)rect animationBlock:(void(^)(void))animationBlock completionBlock:(void(^)(void))completionBlock;


/**
 动画消失
 
 @param rect            回到哪个位置
 @param animationBlock  附带的动画信息
 @param completionBlock 结束的回调
 */
- (void)animationDismissWithToRect:(CGRect)rect animationBlock:(void(^)(void))animationBlock completionBlock:(void(^)(void))completionBlock;
@end
