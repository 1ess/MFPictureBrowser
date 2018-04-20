
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <UIKit/UIKit.h>

@class MFPictureBrowser;
@protocol MFPictureBrowserDelegate <NSObject>
/**
 获取对应索引的视图
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 
 @return 视图
 */
- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index;
@optional

/**
 如果加载网络图片, 实现这个方法
 获取对应索引的高质量图片地址字符串
 
 @param  pictureBrowser 图片浏览器
 @param  index          索引
 
 @return 高质量图片 url 字符串
 */
- (NSString *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageURLAtIndex:(NSInteger)index;
/**
 如果加载本地图片, 实现这个方法
 获取对应索引的高质量图片名称字符串
 
 @param  pictureBrowser 图片浏览器
 @param  index          索引
 
 @return 高质量图片名称
 */
- (NSString *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageNameAtIndex:(NSInteger)index;

/**
 滚动到指定页时会调用该方法
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser scrollToIndex:(NSInteger)index;

/**
 占位图
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 */
- (UIImage *)pictureBrowser:(MFPictureBrowser *)pictureBrowser placeholderImageAtIndex:(NSInteger)index;

/**
 网络图片加载完毕的回调
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 @param image          加载成功返回的image
 @param error          error信息
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageDidLoadAtIndex:(NSInteger)index image:(UIImage *)image error:(NSError *)error;

/**
 browser dimiss时的回调
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser dimissAtIndex:(NSInteger)index;

/**
 长按会调用此方法
 @param pictureBrowser 图片浏览器
 @param index          索引
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser longPressAtIndex:(NSInteger)index;

@end

@interface MFPictureBrowser : UIView
@property (nonatomic, weak) id<MFPictureBrowserDelegate> delegate;
/**
 图片之间的间距，默认： 20
 */
@property (nonatomic, assign) CGFloat imagesSpacing;

/**
 页数文字中心点，默认：居中，中心 y 距离底部 20
 */
@property (nonatomic, assign) CGPoint pageTextCenter;

/**
 页数文字字体，默认：系统字体，16号
 */
@property (nonatomic, strong) UIFont *pageTextFont;

/**
 页数文字颜色，默认：白色
 */
@property (nonatomic, strong) UIColor *pageTextColor;

/**
 显示本地图片浏览器
 
 @param fromView            用户点击的视图
 @param picturesCount       图片的张数
 @param currentPictureIndex 当前用户点击的图片索引
 */
- (void)showLocalImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex;
/**
 显示网络图片浏览器
 
 @param fromView            用户点击的视图
 @param picturesCount       图片的张数
 @param currentPictureIndex 当前用户点击的图片索引
 */
- (void)showNetworkImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex;

/**
 让图片浏览器消失
 */
- (void)dismiss;

@end
