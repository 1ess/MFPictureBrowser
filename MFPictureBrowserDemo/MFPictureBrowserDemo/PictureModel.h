//
//  PictureModel.h
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/18.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MFImageType) {
    MFImageTypeOther,
    MFImageTypeGIF,
    MFImageTypeLongImage
};
@interface PictureModel : NSObject
@property (nonatomic, strong) NSString *imageURL;
@property (nonatomic, assign) MFImageType imageType;
- (instancetype)initWithURL:(NSString *)imageURL  imageType:(MFImageType)imageType;
@end
