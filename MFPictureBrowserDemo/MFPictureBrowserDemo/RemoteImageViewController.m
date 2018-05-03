

#import "RemoteImageViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import "MFPictureModel.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINCache/PINCache.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import "MFPictureBrowser/UIImageView+TransitionImage.h"
#import "MFPictureBrowser/UIImage+ForceDecoded.h"
#import <PINRemoteImage/PINImage+WebP.h>
@interface RemoteImageViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, assign) NSInteger currentIndex;
@end

@implementation RemoteImageViewController

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(10, 10, [UIScreen mainScreen].bounds.size.width - 20, [UIScreen mainScreen].bounds.size.height - 20) collectionViewLayout:flow];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.bounces = NO;
    }
    return _collectionView;
}

- (NSMutableArray *)picList {
    if (!_picList) {
        _picList = @[].mutableCopy;
    }
    return _picList;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[MFDisplayPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"reuseCell"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[[PINRemoteImageManager sharedImageManager] cache] removeAllObjects];
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
    MFPictureModel *pictureModel = self.picList[indexPath.row];
    NSURL *url = [NSURL URLWithString:pictureModel.imageURL];
    [cell.displayImageView setPin_updateWithProgress:YES];
    __weak MFDisplayPhotoCollectionViewCell *weakCell = cell;
    weakCell.displayImageView.alpha = 0;
    if (pictureModel.imageType == MFImageTypeGIF) {
        if (pictureModel.animatedImage) {
            weakCell.displayImageView.animatedImage = pictureModel.flAnimatedImage;
            if (!pictureModel.hidden) {
                weakCell.displayImageView.alpha = 1.0f;
            }
            [self configTagImageView:weakCell.tagImageView imageType:MFImageTypeGIF];
        }else {
            [weakCell.displayImageView pin_setImageFromURL:url placeholderImage:pictureModel.posterImage ?: pictureModel.placeholderImage completion:^(PINRemoteImageManagerResult * _Nonnull result) {
                if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!pictureModel.hidden) {
                            if (result.requestDuration > 0.25) {
                                [UIView animateWithDuration:0.3 animations:^{
                                    weakCell.displayImageView.alpha = 1.0f;
                                }];
                            } else {
                                weakCell.displayImageView.alpha = 1.0f;
                            }
                        }else {
                            weakCell.displayImageView.alpha = 0.0f;
                        }
                    });
                    pictureModel.flAnimatedImage = result.animatedImage;
                    NSData *animatedData = result.animatedImage.data;
                    UIImage *animatedImage = [UIImage forceDecodedImageWithData:animatedData];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        pictureModel.posterImage = animatedImage.images.firstObject;
                        pictureModel.animatedImage = animatedImage;
                        [self configTagImageView:weakCell.tagImageView imageType:MFImageTypeGIF];
                    });
                }
            }];
        }
    }else if (pictureModel.imageType == MFImageTypeNormalWebP) {
        if (pictureModel.posterImage) {
            weakCell.displayImageView.image = pictureModel.posterImage;
            if (!pictureModel.hidden) {
                weakCell.displayImageView.alpha = 1.0f;
            }
            [self configTagImageView:weakCell.tagImageView imageType:pictureModel.imageType];
        }else {
            [weakCell.displayImageView pin_setImageFromURL:url placeholderImage:pictureModel.posterImage ?: pictureModel.placeholderImage completion:^(PINRemoteImageManagerResult * _Nonnull result) {
                if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!pictureModel.hidden) {
                            if (result.requestDuration > 0.25) {
                                [UIView animateWithDuration:0.3 animations:^{
                                    weakCell.displayImageView.alpha = 1.0f;
                                }];
                            } else {
                                weakCell.displayImageView.alpha = 1.0f;
                            }
                        }else {
                            weakCell.displayImageView.alpha = 0.0f;
                        }
                    });
                    dispatch_async(dispatch_get_main_queue(), ^{
                        pictureModel.posterImage = result.image;
                        [self configTagImageView:weakCell.tagImageView imageType:pictureModel.imageType];
                    });
                }
            }];
        }
    }else {
        if (pictureModel.posterImage) {
            weakCell.displayImageView.image = pictureModel.posterImage;
            if (!pictureModel.hidden) {
                weakCell.displayImageView.alpha = 1.0f;
            }
            [self configTagImageView:weakCell.tagImageView imageType:pictureModel.imageType];
        }else {
            [weakCell.displayImageView pin_setImageFromURL:url placeholderImage:pictureModel.placeholderImage completion:^(PINRemoteImageManagerResult * _Nonnull result) {
                if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (!pictureModel.hidden) {
                            if (result.requestDuration > 0.25) {
                                [UIView animateWithDuration:0.3 animations:^{
                                    weakCell.displayImageView.alpha = 1.0f;
                                }];
                            } else {
                                weakCell.displayImageView.alpha = 1.0f;
                            }
                        }else {
                            weakCell.displayImageView.alpha = 0.0f;
                        }
                        pictureModel.posterImage = result.image;
                        [self configTagImageView:weakCell.tagImageView imageType:pictureModel.imageType];
                    });
                }
            }];
        }
    }
    return cell;
}

- (void)configTagImageView:(UIImageView *)tagImageView imageType:(MFImageType)imageType {
    if (imageType == MFImageTypeLongImage) {
        tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
    }else if (imageType == MFImageTypeGIF || imageType == MFImageTypeAnimatedWebP) {
        tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
    }else {
        tagImageView.image = nil;
    }
    tagImageView.alpha = 0;
    if (tagImageView.image) {
        tagImageView.alpha = 1;
    }
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
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MFPictureBrowser *browser = [[MFPictureBrowser alloc] init];
    browser.delegate = self;
    self.currentIndex = indexPath.row;
    MFPictureModel *pictureModel = self.picList[indexPath.row];
    pictureModel.hidden = true;
    [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    [browser showImageFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

- (id<MFPictureModelProtocol>)pictureBrowser:(MFPictureBrowser *)pictureBrowser pictureModelAtIndex:(NSInteger)index {
    MFPictureModel *pictureModel = self.picList[index];
    return pictureModel;
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser image:(UIImage *)image animatedImage:(UIImage *)animatedImage didLoadAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFPictureModel *pictureModel = self.picList[index];
    if (animatedImage) {
        pictureModel.posterImage = animatedImage.images.firstObject;
    }else if (image) {
        pictureModel.posterImage = image;
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser scrollToIndex:(NSInteger)index {
    MFPictureModel *pictureModel = self.picList[self.currentIndex];
    pictureModel.hidden = false;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentIndex inSection:0]]];
    self.currentIndex = index;
    MFPictureModel *currentPictureModel = self.picList[self.currentIndex];
    currentPictureModel.hidden = true;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.currentIndex inSection:0]]];
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser dimissAtIndex:(NSInteger)index {
    MFPictureModel *pictureModel = self.picList[index];
    pictureModel.hidden = false;
    [self.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
}

@end
