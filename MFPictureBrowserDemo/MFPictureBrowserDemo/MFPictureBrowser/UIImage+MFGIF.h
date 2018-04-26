//
//  UIImage+MFGIF.h
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/26.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (MFGIF)
+ (UIImage *)animatedGIFWithData:(NSData *)data;
@end
