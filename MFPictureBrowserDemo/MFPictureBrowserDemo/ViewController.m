//
//  ViewController.m
//  MFPictureBrowserDemo
//
//  Created by 张冬冬 on 2018/4/17.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "ViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import <YYWebImage.h>
@interface ViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *picList;
@end

@implementation ViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 0, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.width - 20) collectionViewLayout:flow];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (NSMutableArray *)picList {
    if (!_picList) {
        _picList = @[
                     @"https://cdn.dribbble.com/users/571755/screenshots/4479924/captainjet-app.jpg",
                     @"https://pic4.zhimg.com/v2-fd1ed42848c7887efb60c3ab9927308b_b.gif",
                     @"https://pic2.zhimg.com/v2-4429bf94b04e5e72a44a38387867a91d_b.gif",
                     @"https://pic1.zhimg.com/6f19a4976f57c61e87507bc19f5d6c64_r.jpg",
                     @"https://pic4.zhimg.com/v2-3f7510e46f5014e0373d769d5b9cfbeb_b.gif"
                     ].mutableCopy;
    }
    return _picList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MFDisplayPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.picList.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)collectionView
                  cellForItemAtIndexPath: (NSIndexPath *)indexPath {
    
    MFDisplayPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"reuseCell" forIndexPath:indexPath];
    NSString *picUrlString = self.picList[indexPath.row];
    NSURL *url = [NSURL URLWithString:picUrlString];
    [cell.displayImageView yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"placeholder"] options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (!error) {
            NSData *data = [self contentDataWithImage:image andURL:url];
            CFDataRef dataRef = CFBridgingRetain(data);
            dispatch_async(dispatch_get_main_queue(), ^{
                YYImageType type = YYImageDetectType(dataRef);
                CFBridgingRelease(dataRef);
                CGFloat height = image.size.height * 320 / image.size.width;
                if (height > [UIScreen mainScreen].bounds.size.height) {
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                }
                else if (type == YYImageTypeGIF) {
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                }
                
                if (cell.tagImageView.image) {
                    cell.tagImageView.alpha = 1;
                }
            });
        }
    }];
    
    return cell;
}

- (NSData *)contentDataWithImage:(UIImage *)image andURL:(NSURL *)url {
    NSData *data = nil;
    if ([image isKindOfClass:[YYImage class]]) {
        data = ((YYImage *)image).animatedImageData;
    }
    if (!data) {
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        NSString *key = [manager cacheKeyForURL:url];
        data = [manager.cache getImageDataForKey:key];
    }
    
    return data;
}

- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath *)indexPath{
    return CGSizeMake(([UIScreen mainScreen].bounds.size.width - 20 - 20)/3, ([UIScreen mainScreen].bounds.size.width - 20 - 20)/3);
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumLineSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (CGFloat)collectionView: (UICollectionView *)collectionView
                   layout: (UICollectionViewLayout*)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex: (NSInteger)section{
    return 5.0f;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(5, 5, 5, 5);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    MFPictureBrowser *brower = [[MFPictureBrowser alloc] init];
    brower.delegate = self;
    [brower showFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (NSString *)pictureView:(MFPictureBrowser *)pictureBrowser imageURLAtIndex:(NSInteger)index {
    return self.picList[index];
}

- (UIView *)pictureView:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

- (void)pictureView:(MFPictureBrowser *)pictureBrowser didLoadImageAtIndex:(NSInteger)index withError:(NSError *)error{
    if (!error) {
        YYWebImageManager *manager = [YYWebImageManager sharedManager];
        NSString *key = [manager cacheKeyForURL:[NSURL URLWithString:self.picList[index]]];
        UIImage *image = [manager.cache getImageForKey:key];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (image != cell.displayImageView.image) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            cell.displayImageView.alpha = 0;
        }
    }
}


@end
