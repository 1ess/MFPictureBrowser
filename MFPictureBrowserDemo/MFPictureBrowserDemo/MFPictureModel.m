

#import "MFPictureModel.h"

@implementation MFPictureModel
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType {
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil compressed:true];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType compressed:(BOOL)compressed{
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil compressed:compressed];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType placeholderImage:(UIImage *)palceholderImage posterImage:(UIImage *)posterImage animatedImage:(UIImage *)animatedImage compressed:(BOOL)compressed {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _imageName = imageName;
        _imageType = imageType;
        _placeholderImage = palceholderImage;
        _posterImage = posterImage;
        _animatedImage = animatedImage;
        _compressed = compressed;
    }
    return self;
}
@end
