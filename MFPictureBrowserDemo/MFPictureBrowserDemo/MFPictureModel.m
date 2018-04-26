

#import "MFPictureModel.h"

@implementation MFPictureModel
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType {
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil decoded:true];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType decode:(BOOL)decode{
    return [self initWithURL:imageURL imageName:imageName imageType:imageType placeholderImage:[UIImage imageNamed:@"placeholder"] posterImage:nil animatedImage:nil decoded:decode];
}

- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType placeholderImage:(UIImage *)palceholderImage posterImage:(UIImage *)posterImage animatedImage:(UIImage *)animatedImage decoded:(BOOL)decoded {
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _imageName = imageName;
        _imageType = imageType;
        _placeholderImage = palceholderImage;
        _posterImage = posterImage;
        _animatedImage = animatedImage;
        _decoded = decoded;
    }
    return self;
}
@end
