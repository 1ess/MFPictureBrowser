

#import "ListViewController.h"
#import "RemoteImageViewController.h"
#import "LocalImageViewController.h"
#import "MFPictureModel.h"
@interface ListViewController ()
<
UITableViewDelegate,
UITableViewDataSource
>
@property (nonatomic, strong) NSArray *list;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation ListViewController

- (NSArray *)list {
    if (!_list) {
        _list = @[
                  @"网络图片",
                  @"本地图片",
                  @"网络福利",
                  @"本地福利",
                  ];
    }
    return _list;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:(UITableViewStyleGrouped)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (!indexPath.row) {
        RemoteImageViewController *remote = [[RemoteImageViewController alloc] init];
        remote.picList = @[
                           [[MFPictureModel alloc] initWithURL:@"https://pic2.zhimg.com/80/v2-9d0d69e867ed790715fa11d1c55f3151_hd.jpg"
                                                     imageName:nil
                                                     imageType:MFImageTypeOther],
                           [[MFPictureModel alloc] initWithURL:@"https://ww3.sinaimg.cn/mw690/79ba7be1jw1e5jdfqobcdg20bh06gwwz.gif"
                                                     imageName:nil
                                                     imageType:MFImageTypeGIF],
                           [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903092531_ZTaFm.gif"
                                                     imageName:nil
                                                     imageType:MFImageTypeGIF],
                           [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903092605_3KdcV.gif"
                                                     imageName:nil
                                                     imageType:MFImageTypeGIF],
                           [[MFPictureModel alloc] initWithURL:@"https://pic2.zhimg.com/e336f051665a796be2d86ab37aa1ffb9_r.jpg"
                                                     imageName:nil
                                                     imageType:MFImageTypeLongImage],
                           [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903085932_PTrKh.gif"
                                                     imageName:nil
                                                     imageType:MFImageTypeGIF],
                           [[MFPictureModel alloc] initWithURL:@"https://b-ssl.duitang.com/uploads/item/201609/03/20160903085850_ZHaP5.gif"
                                                     imageName:nil
                                                     imageType:MFImageTypeGIF],
                           [[MFPictureModel alloc] initWithURL:@"https://p.upyun.com/demo/webp/webp/png-3.webp"
                                                     imageName:nil
                                                     imageType:MFImageTypeNormalWebP],
                           ].mutableCopy;
        [self.navigationController pushViewController:remote animated:true];
    }else if (indexPath.row == 1) {
        LocalImageViewController *local = [[LocalImageViewController alloc] init];
        local.picList = @[
                          [[MFPictureModel alloc] initWithURL:nil imageName:@"1.gif" imageType:MFImageTypeGIF],
                          [[MFPictureModel alloc] initWithURL:nil imageName:@"2.gif" imageType:MFImageTypeGIF],
                          [[MFPictureModel alloc] initWithURL:nil imageName:@"1.webp" imageType:MFImageTypeNormalWebP],
                          [[MFPictureModel alloc] initWithURL:nil imageName:@"4.jpg" imageType:MFImageTypeOther],
                          [[MFPictureModel alloc] initWithURL:nil imageName:@"5.jpg" imageType:MFImageTypeLongImage],
                          ].mutableCopy;
        [self.navigationController pushViewController:local animated:true];
    }else if (indexPath.row == 2) {
        RemoteImageViewController *remoteWelfare = [[RemoteImageViewController alloc] init];
        remoteWelfare.picList = @[
                                  [[MFPictureModel alloc] initWithURL:@"http://7xi8d6.com1.z0.glb.clouddn.com/20180122090204_A4hNiG_Screenshot.jpeg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://7xi8d6.com1.z0.glb.clouddn.com/20171114101305_NIAzCK_rakukoo_14_11_2017_10_12_58_703.jpeg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"https://ws1.sinaimg.cn/large/610dc034ly1fjndz4dh39j20u00u0ada.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"https://ws1.sinaimg.cn/large/610dc034ly1fibksd2mbmj20u011iacx.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://7xi8d6.com1.z0.glb.clouddn.com/2017-05-12-18380140_455327614813449_854681840315793408_n.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://ww1.sinaimg.cn/large/61e74233ly1feuogwvg27j20p00zkqe7.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://7xi8d6.com1.z0.glb.clouddn.com/2017-03-13-17265708_396005157434387_3099040288153272320_n.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://7xi8d6.com1.z0.glb.clouddn.com/2017-03-02-16906481_1495916493759925_5770648570629718016_n.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  [[MFPictureModel alloc] initWithURL:@"http://ww2.sinaimg.cn/large/610dc034gw1f9lmfwy2nij20u00u076w.jpg"
                                                            imageName:nil
                                                            imageType:MFImageTypeOther],
                                  ].mutableCopy;
        [self.navigationController pushViewController:remoteWelfare animated:YES];
    }else {
        LocalImageViewController *localWelfare = [[LocalImageViewController alloc] init];
        localWelfare.picList = @[
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"6.jpg" imageType:MFImageTypeOther],
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"7.jpg" imageType:MFImageTypeOther],
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"8.jpg" imageType:MFImageTypeOther],
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"9.jpg" imageType:MFImageTypeOther],
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"10.jpg" imageType:MFImageTypeOther],
                                 [[MFPictureModel alloc] initWithURL:nil imageName:@"11.jpg" imageType:MFImageTypeOther],
                                 ].mutableCopy;
        [self.navigationController pushViewController:localWelfare animated:YES];
    }
}

@end
