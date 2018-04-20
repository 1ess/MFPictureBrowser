

#import "RemoteImageViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import <YYWebImage.h>
#import "PictureModel.h"
@interface RemoteImageViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *picList;
@end

@implementation RemoteImageViewController

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
                     [[PictureModel alloc] initWithURL:@"https://pic2.zhimg.com/80/v2-9d0d69e867ed790715fa11d1c55f3151_hd.jpg"
                                             imageType:MFImageTypeOther],
                     [[PictureModel alloc] initWithURL:@"https://cdn.dribbble.com/users/5031/screenshots/3713646/mikaelgustafsson_mklgustafsson.gif"
                                             imageType:MFImageTypeGIF],
                     [[PictureModel alloc] initWithURL:@"https://cdn.dribbble.com/users/469578/screenshots/2597126/404-drib23.gif"
                                             imageType:MFImageTypeGIF],
                     [[PictureModel alloc] initWithURL:@"https://cdn.dribbble.com/users/107759/screenshots/3963668/link-final.gif"
                                             imageType:MFImageTypeGIF],
                     [[PictureModel alloc] initWithURL:@"https://pic2.zhimg.com/e336f051665a796be2d86ab37aa1ffb9_r.jpg"
                                             imageType:MFImageTypeLongImage]
                     ].mutableCopy;
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
    YYImageCache *cache = [YYWebImageManager sharedManager].cache;
    [cache.memoryCache removeAllObjects];
    [cache.diskCache removeAllObjects];
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
    PictureModel *model = self.picList[indexPath.row];
    NSString *picUrlString = model.imageURL;
    NSURL *url = [NSURL URLWithString:picUrlString];
    [cell.displayImageView yy_setImageWithURL:url placeholder:[UIImage imageNamed:@"placeholder"] options:YYWebImageOptionProgressive completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
        if (!error && stage == YYWebImageStageFinished) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (model.imageType == MFImageTypeGIF) {
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                    cell.tagImageView.alpha = 1;
                }else if (model.imageType == MFImageTypeLongImage) {
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                    cell.tagImageView.alpha = 1;
                }else {
                    cell.tagImageView.image = nil;
                    cell.tagImageView.alpha = 0;
                }
            });
        }
    }];
    
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
    NSLog(@"%@", cell.displayImageView.image);
    
    MFPictureBrowser *browser = [[MFPictureBrowser alloc] init];
    browser.delegate = self;
    [browser showNetworkImageFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

- (NSString *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageURLAtIndex:(NSInteger)index {
    PictureModel *model = self.picList[index];
    return model.imageURL;
}

- (UIImage *)pictureBrowser:(MFPictureBrowser *)pictureBrowser placeholderImageAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView.image ?: [UIImage imageNamed:@"placeholder"];
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageDidLoadAtIndex:(NSInteger)index image:(UIImage *)image error:(NSError *)error {
    [self.collectionView reloadData];
}


@end
