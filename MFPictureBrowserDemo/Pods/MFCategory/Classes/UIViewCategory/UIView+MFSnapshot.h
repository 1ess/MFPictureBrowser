//
//  UIView+MFSnapshot.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (MFSnapshot)
- (UIImage *)viewSnapshot;
- (UIImage *)layerSnapshot;
@end
