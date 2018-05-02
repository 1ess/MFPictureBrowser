

#import "MFPictureModel.h"

@implementation MFPictureModel
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType {
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil flAnimatedImage:nil compressed:true hidden:false];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType compressed:(BOOL)compressed hidden:(BOOL)hidden {
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil flAnimatedImage:nil compressed:compressed hidden:false];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType placeholderImage:(UIImage *)palceholderImage posterImage:(UIImage *)posterImage animatedImage:(UIImage *)animatedImage flAnimatedImage:(FLAnimatedImage *)flAnimatedImage compressed:(BOOL)compressed hidden:(BOOL)hidden {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _imageName = imageName;
        _imageType = imageType;
        _placeholderImage = palceholderImage;
        _posterImage = posterImage;
        _animatedImage = animatedImage;
        _flAnimatedImage = flAnimatedImage;
        _compressed = compressed;
        _hidden = hidden;
    }
    return self;
}
@end
