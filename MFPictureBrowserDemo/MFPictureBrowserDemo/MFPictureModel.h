

#import <Foundation/Foundation.h>
#import "MFPictureModelProtocol.h"

@interface MFPictureModel : NSObject
<
MFPictureModelProtocol
>
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign) MFImageType imageType;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, strong) UIImage *posterImage;
@property (nonatomic, strong) UIImage *animatedImage;
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType;
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType placeholderImage:(UIImage *)palceholderImage posterImage:(UIImage *)posterImage animatedImage:(UIImage *)animatedImage;
@end
