//
//  PictureModel.m
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/18.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "PictureModel.h"

@implementation PictureModel
- (instancetype)initWithURL:(NSString *)imageURL imageType:(MFImageType)imageType isHidden:(BOOL)hidden
{
    self = [super init];
    if (self) {
        _imageURL = imageURL;
        _imageType = imageType;
        _hidden = hidden;
    }
    return self;
}
@end
