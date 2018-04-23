
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <UIKit/UIKit.h>
#import <FLAnimatedImage/FLAnimatedImageView.h>
@class MFPictureView;
@protocol MFPictureViewDelegate <NSObject>
- (void)pictureView:(MFPictureView *)pictureView didClickAtIndex:(NSInteger)index;
- (void)pictureView:(MFPictureView *)pictureView scale:(CGFloat)scale;
- (void)pictureView:(MFPictureView *)pictureView image:(UIImage *)image animatedImage:(FLAnimatedImage *)animatedImage didLoadAtIndex:(NSInteger)index;
@end

@interface MFPictureView : UIScrollView
// 当前视图所在的索引
@property (nonatomic, assign) NSInteger index;
// 图片的大小
@property (nonatomic, assign) CGSize pictureSize;
// 已经解码完的 animatedImage
@property (nonatomic, strong) FLAnimatedImage *decodedAnimatedImage;
// 图片的地址 URL
@property (nonatomic, strong) NSString *imageURL;
// 本地图片名
@property (nonatomic, strong) NSString *imageName;
// 当前显示图片的控件
@property (nonatomic, strong, readonly) FLAnimatedImageView *imageView;
// 代理
@property (nonatomic, weak) id<MFPictureViewDelegate> pictureDelegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithImageName:(NSString *)imageName decodedAnimatedImage:(FLAnimatedImage *)decodedAnimatedImage;
- (instancetype)initWithImageURL:(NSString *)imageURL decodedAnimatedImage:(FLAnimatedImage *)decodedAnimatedImage;

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
