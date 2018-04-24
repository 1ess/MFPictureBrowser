

#import "WelfareViewController.h"
#import "MFPictureBrowser.h"
#import "MFDisplayPhotoCollectionViewCell.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>
#import "MFPictureBrowser/FLAnimatedImageView+TransitionImage.h"
#import "MFPictureModel.h"
@interface WelfareViewController ()
<
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDelegateFlowLayout,
MFPictureBrowserDelegate
>
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *picList;
@end

@implementation WelfareViewController

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
        _picList = @[
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"6.jpg" imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"7.jpg" imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"8.jpg" imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"9.jpg" imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"10.jpg" imageType:MFImageTypeOther],
                     [[MFPictureModel alloc] initWithURL:nil imageName:@"11.jpg" imageType:MFImageTypeOther],
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
    
    if (pictureModel.imageType == MFImageTypeGIF) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSURL *imageURL = [[NSBundle mainBundle] URLForResource:pictureModel.imageName withExtension:nil];
            FLAnimatedImage *animatedImage = [FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfURL:imageURL]];
            if (animatedImage) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [cell.displayImageView animatedTransitionAnimatedImage:animatedImage];
                    [self configTagImageView:cell.tagImageView size:animatedImage.size imageType:MFImageTypeGIF];
                });
            }
        });
    }else {
        UIImage *image = [UIImage imageNamed:pictureModel.imageName];
        cell.displayImageView.image = image;
        [self configTagImageView:cell.tagImageView size:image.size imageType:pictureModel.imageType];
    }
    return cell;
}

- (void)configTagImageView:(UIImageView *)tagImageView size:(CGSize)size imageType:(MFImageType)imageType {
    if (imageType == MFImageTypeLongImage) {
        tagImageView.image = [UIImage imageNamed:@"ic_messages_pictype_long_pic_30x30_"];
    }else if (imageType == MFImageTypeGIF) {
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
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    MFDisplayPhotoCollectionViewCell *cell = (MFDisplayPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    MFPictureBrowser *browser = [[MFPictureBrowser alloc] init];
    browser.delegate = self;
    [browser showImageFromView:cell.displayImageView picturesCount:self.picList.count currentPictureIndex:indexPath.row];
}

- (FLAnimatedImageView *)pictureBrowser:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
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
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}

@end
