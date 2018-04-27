
//  Copyright © 2018年 GodzzZZZ. All rights reserved.

#import <UIKit/UIKit.h>

@interface UIImage (ForceDecoded)
+ (UIImage *)forceDecodedImageWithData:(NSData *)data;
+ (UIImage *)forceDecodedImageWithData:(NSData *)data compressed:(BOOL)compressed;
@end
