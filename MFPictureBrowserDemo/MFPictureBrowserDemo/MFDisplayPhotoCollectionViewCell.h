//
//  MFDisplayPhotoCollectionViewCell.h
//  软装
//
//  Created by 张冬冬 on 2018/1/30.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYImage.h>
@interface MFDisplayPhotoCollectionViewCell : UICollectionViewCell
@property (nonatomic ,strong) YYAnimatedImageView *displayImageView;
@property (nonatomic, strong) UIImageView *tagImageView;
@end
