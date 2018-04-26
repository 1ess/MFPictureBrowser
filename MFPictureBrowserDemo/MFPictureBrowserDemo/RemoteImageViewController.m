

#import "RemoteImageViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import "MFPictureModel.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import <PINCache/PINCache.h>
#import <PINRemoteImage/PINRemoteImage.h>
#import "MFPictureBrowser/FLAnimatedImageView+TransitionImage.h"
@interface RemoteImageViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
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
//    [[[PINRemoteImageManager sharedImageManager] cache] removeAllObjects];
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
    if (pictureModel.imageType == MFImageTypeGIF) {
        NSString *cacheKey = [[PINRemoteImageManager sharedImageManager] cacheKeyForURL:url processorKey:nil];
        PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
        BOOL imageAvailable = [cache containsObjectForKey:cacheKey];
        if (imageAvailable) {
            [cache objectForKey:cacheKey block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:object];
                if (animatedImage) {
                    pictureModel.posterImage = animatedImage.posterImage;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakCell.displayImageView animatedTransitionAnimatedImage:animatedImage];
                        weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                        weakCell.tagImageView.alpha = 1;
                    });
                }
            }];
        }else {
            [[PINRemoteImageManager sharedImageManager] downloadImageWithURL:url options:(PINRemoteImageManagerDownloadOptionsNone) progressDownload:nil completion:^(PINRemoteImageManagerResult * _Nonnull result) {
                if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        pictureModel.posterImage = result.animatedImage.posterImage;
                        if (result.requestDuration > 0.25) {
                            [weakCell.displayImageView animatedTransitionAnimatedImage:result.animatedImage];
                        } else {
                            weakCell.displayImageView.animatedImage = result.animatedImage;
                        }
                        weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                        weakCell.tagImageView.alpha = 1;
                    });
                }
            }];
        }
    }else {
        NSString *cacheKey = [[PINRemoteImageManager sharedImageManager] cacheKeyForURL:url processorKey:nil];
        PINCache *cache = [PINRemoteImageManager sharedImageManager].cache;
        BOOL imageAvailable = [cache containsObjectForKey:cacheKey];
        if (imageAvailable) {
            [cache objectForKey:cacheKey block:^(PINCache * _Nonnull cache, NSString * _Nonnull key, id  _Nullable object) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([object isKindOfClass:[NSData class]]) {
                        [weakCell.displayImageView animatedTransitionImage:[UIImage imageWithData:object]];
                    }else if ([object isKindOfClass:[UIImage class]]) {
                        [weakCell.displayImageView animatedTransitionImage:object];
                    }
                    pictureModel.posterImage = weakCell.displayImageView.image;
                    if (pictureModel.imageType == MFImageTypeLongImage) {
                        weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                        weakCell.tagImageView.alpha = 1;
                    }else {
                        weakCell.tagImageView.image = nil;
                        weakCell.tagImageView.alpha = 0;
                    }
                });
            }];
        }else {
            [[PINRemoteImageManager sharedImageManager] downloadImageWithURL:url options:(PINRemoteImageManagerDownloadOptionsNone) progressDownload:nil completion:^(PINRemoteImageManagerResult * _Nonnull result) {
                if (!result.error && (result.resultType == PINRemoteImageResultTypeDownload || result.resultType == PINRemoteImageResultTypeMemoryCache || result.resultType == PINRemoteImageResultTypeCache)) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (result.requestDuration > 0.25) {
                            [weakCell.displayImageView animatedTransitionImage:result.image];
                        } else {
                            weakCell.displayImageView.image = result.image;
                        }
                        pictureModel.posterImage = weakCell.displayImageView.image;
                        if (pictureModel.imageType == MFImageTypeLongImage) {
                            weakCell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                            weakCell.tagImageView.alpha = 1;
                        }else {
                            weakCell.tagImageView.image = nil;
                            weakCell.tagImageView.alpha = 0;
                        }
                    });
                }
            }];
        }
    }

    return cell;
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

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageDidLoadAtIndex:(NSInteger)index image:(UIImage *)image animatedImage:(FLAnimatedImage *)animatedImage error:(NSError *)error {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFPictureModel *pictureModel = self.picList[index];
    if (animatedImage) {
        pictureModel.posterImage = animatedImage.posterImage;
    }else if (image) {
        pictureModel.posterImage = image;
    }
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
