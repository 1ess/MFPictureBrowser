
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <YYImage/YYImage.h>
typedef NS_ENUM(NSInteger, MFImageType) {
    MFImageTypeUnknown,
    MFImageTypeOther,
    MFImageTypeGIF,
    MFImageTypeAnimatedWebP,
    MFImageTypeStaticWebP,
    MFImageTypeLongImage
};
@protocol MFPictureModelProtocol <NSObject>
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) MFImageType imageType;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, strong) UIImage *animatedImage;
@property (nonatomic, strong) YYImage *webpAnimatedImage;
@property (nonatomic, assign) BOOL compressed;
@end
