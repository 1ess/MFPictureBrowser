# MFPictureBrowser

# BUG极多, 周末我会解决, I Promise.

类似于<即刻>应用的图片浏览器效果
[参考：ESPictureBrowser](https://github.com/EnjoySR/ESPictureBrowser), 提交了 PR, 但原作者可能不维护了, 所以我重新写了一下, 并修改了其中一些 bug.

## 效果图

<img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/Snapshot/3.gif" width="50%"/><img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/Snapshot/4.gif" width="50%"/>

## 集成方式
- cocoapod

```
pod 'MFPictureBrowser'
```

## 使用方式
- 导入

```objc
#import <MFPictureBrowser.h>
```

- 初始化并设置代理

```objc
MFPictureBrowser *brower = [[MFPictureBrowser alloc] init];
brower.delegate = self;
```
- 展示

```objc
//展示本地图片
[brower showLocalImageFromView:(fromView) picturesCount:(picturesCount) currentPictureIndex:(currentPictureIndex)];

//展示网络图片
[brower showNetworkImageFromView:(fromView) picturesCount:(picturesCount) currentPictureIndex:(currentPictureIndex)];
```

- 实现代理方法

```objc
//必须实现
- (UIImageView *)pictureView:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    ...
}

//可选实现下面任一方法
- (NSString *)pictureView:(MFPictureBrowser *)pictureBrowser imageURLAtIndex:(NSInteger)index {
    ...
}

- (NSString *)pictureView:(MFPictureBrowser *)pictureBrowser imageNameAtIndex:(NSInteger)index {
    ...
}
```

具体使用方式参见 Demo

