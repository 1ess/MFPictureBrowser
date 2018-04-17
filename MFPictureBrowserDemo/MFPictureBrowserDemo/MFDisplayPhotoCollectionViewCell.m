

#import "MFDisplayPhotoCollectionViewCell.h"

@implementation MFDisplayPhotoCollectionViewCell
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor clearColor];
        
        self.displayImageView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.displayImageView.layer.cornerRadius = 2;
        self.displayImageView.layer.masksToBounds = YES;
        self.displayImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.displayImageView];
        
        self.tagImageView = [[UIImageView alloc] initWithFrame:CGRectMake(frame.size.width - 32, frame.size.height - 30, 30, 30)];
        self.tagImageView.alpha = 0;
        [self.displayImageView addSubview:self.tagImageView];
        
    }
    return self;
}
@end
