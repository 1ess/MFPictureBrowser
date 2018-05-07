# MFPictureBrowser

类似于<即刻>应用的图片浏览器效果(支持PNG， JPG， GIF， WebP).

## 效果图

<img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/SnapShot/1.webp" width="25%"/><img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/SnapShot/2.webp" width="25%"/><img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/SnapShot/3.webp" width="25%"/><img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/SnapShot/4.webp" width="25%"/>

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
//展示图片
[brower showImageFromView:(fromView) picturesCount:(picturesCount) currentPictureIndex:(currentPictureIndex)];
```

 实现代理方法

```objc

- (FLAnimatedImageView *)pictureView:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    ...
}

- (id<MFPictureModelProtocol>)pictureBrowser:(MFPictureBrowser *)pictureBrowser pictureModelAtIndex:(NSInteger)index {
    ...
}
```

具体使用方式参见 Demo

## 感谢
[ESPictureBrowser](https://github.com/EnjoySR/ESPictureBrowser)

[YYWebImage](https://github.com/ibireme/YYWebImage)
