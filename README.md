# [废弃]MFPictureBrowser

类似于<即刻>应用的图片浏览器效果(支持PNG， JPG， GIF， WebP).

![DUB](https://img.shields.io/dub/l/vibe-d.svg)
![Total-downloads](https://img.shields.io/cocoapods/dt/MFPictureBrowser.svg)
![Version](https://img.shields.io/cocoapods/v/MFPictureBrowser.svg?style=flat)
![Platform](https://img.shields.io/cocoapods/p/MFPictureBrowser.svg?style=flat)
![Language](https://img.shields.io/badge/language-objectivec-blue.svg)

## 效果图

<img src="https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/1.gif" width="25%"><img src="https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/2.gif" width="25%"><img src="https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/3.gif" width="25%"><img src="https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/4.gif" width="25%">

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
