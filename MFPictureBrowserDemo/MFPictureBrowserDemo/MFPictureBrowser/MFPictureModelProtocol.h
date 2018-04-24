

#import <Foundation/Foundation.h>
#import <FLAnimatedImage/FLAnimatedImage.h>
typedef NS_ENUM(NSInteger, MFImageType) {
    MFImageTypeUnknown,
    MFImageTypeOther,
    MFImageTypeGIF,
    MFImageTypeLongImage
};
@protocol MFPictureModelProtocol <NSObject>
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) MFImageType imageType;
@property (nonatomic, strong) UIImage *posterImage;
@end
