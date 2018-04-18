

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
@property (nonatomic, assign) NSInteger currentPictureIndex;
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
                     [[PictureModel alloc] initWithURL:@"https://cdn.dribbble.com/users/571755/screenshots/4479924/captainjet-app.jpg" isLoad:NO imageType:MFImageTypeOther],
                     [[PictureModel alloc] initWithURL:@"https://pic4.zhimg.com/v2-fd1ed42848c7887efb60c3ab9927308b_b.gif" isLoad:NO imageType:MFImageTypeOther],
                     [[PictureModel alloc] initWithURL:@"https://pic2.zhimg.com/v2-4429bf94b04e5e72a44a38387867a91d_b.gif" isLoad:NO imageType:MFImageTypeOther],
                     [[PictureModel alloc] initWithURL:@"https://pic1.zhimg.com/6f19a4976f57c61e87507bc19f5d6c64_r.jpg" isLoad:NO imageType:MFImageTypeOther],
                     [[PictureModel alloc] initWithURL:@"https://pic4.zhimg.com/v2-3f7510e46f5014e0373d769d5b9cfbeb_b.gif" isLoad:NO imageType:MFImageTypeOther]
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
        if (!error) {
            model.isLoad = YES;
            NSData *data = [self contentDataWithImage:image andURL:url];
            CFDataRef dataRef = CFBridgingRetain(data);
            dispatch_async(dispatch_get_main_queue(), ^{
                YYImageType type = YYImageDetectType(dataRef);
                CFBridgingRelease(dataRef);
                CGFloat height = image.size.height * 320 / image.size.width;
                if (height > [UIScreen mainScreen].bounds.size.height) {
                    model.imageType = MFImageTypeLongImage;
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
                }
                else if (type == YYImageTypeGIF) {
                    model.imageType = MFImageTypeGIF;
                    cell.tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_gif_30x30_"];
                }else {
                    model.imageType = MFImageTypeOther;
                    cell.tagImageView.image = nil;
                }
                cell.tagImageView.alpha = 0;
                if (cell.tagImageView.image) {
                    cell.tagImageView.alpha = 1;
                }
            });
        }else {
            model.isLoad = NO;
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
    self.currentPictureIndex = indexPath.row;
    cell.displayImageView.alpha = 0;
    [brower showFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (NSString *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageURLAtIndex:(NSInteger)index {
    PictureModel *model = self.picList[index];
    return model.imageURL;
}

- (UIImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell.displayImageView;
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser didLoadImageAtIndex:(NSInteger)index withError:(NSError *)error{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    PictureModel *model = self.picList[index];
    if (!error) {
        if (!model.isLoad) {
            [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
        }
        model.isLoad = YES;
    }else {
        model.isLoad = NO;
    }
}

- (void)pictureBrowser:(MFPictureBrowser *)pictureBrowser scrollToIndex:(NSInteger)index {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentPictureIndex inSection:0];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    cell.displayImageView.alpha = 1;
    self.currentPictureIndex = index;
    NSIndexPath *currentIndexPath = [NSIndexPath indexPathForRow:self.currentPictureIndex inSection:0];
    MFDisplayPhotoCollectionViewCell *currentCell = (MFDisplayPhotoCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:currentIndexPath];
    currentCell.displayImageView.alpha = 0;
}

@end
