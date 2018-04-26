
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <UIKit/UIKit.h>
#import "MFPictureModelProtocol.h"
@class MFPictureBrowser;
@protocol MFPictureBrowserDelegate <NSObject>
/**
 获取对应索引的视图
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 
 @return 视图
 */
- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index;
/**
 返回协议对象
 
 @param  pictureBrowser 图片浏览器
 @param  index          索引
 
 @return 协议对象
 */
- (id<MFPictureModelProtocol>)pictureBrowser:(MFPictureBrowser *)pictureBrowser pictureModelAtIndex:(NSInteger)index;
@optional

/**
 滚动到指定页时会调用该方法
 
 @param pictureBrowser 图片浏览器
 @param index          索引
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser scrollToIndex:(NSInteger)index;

/**
 网络图片加载完毕的回调
 
 @param pictureBrowser 图片浏览器
 @param image          加载成功返回的image
 @param animatedImage  加载成功返回的animatedImage
 @param index          索引
 */
- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser image:(UIImage *)image animatedImage:(UIImage *)animatedImage didLoadAtIndex:(NSInteger)index;

/**
 browser did dimiss时的回调
 
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
 显示图片浏览器
 
 @param fromView            用户点击的视图
 @param picturesCount       图片的张数
 @param currentPictureIndex 当前用户点击的图片索引
 */
- (void)showImageFromView:(UIImageView *)fromView picturesCount:(NSInteger)picturesCount currentPictureIndex:(NSInteger)currentPictureIndex;

/**
 让图片浏览器消失
 */
- (void)dismiss;

@end
