

#import <Foundation/Foundation.h>
#import "MFPictureModelProtocol.h"

@interface MFPictureModel : NSObject
<
MFPictureModelProtocol
>
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, assign) MFImageType imageType;
- (instancetype)initWithURL:(NSString *)imageURL imageName:(NSString *)imageName imageType:(MFImageType)imageType;
@end
