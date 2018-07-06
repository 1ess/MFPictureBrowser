# MFPictureBrowser

类似于<即刻>应用的图片浏览器效果(支持PNG， JPG， GIF， WebP).

## 效果图
![video 1](https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/1.mp4)
![video 2](https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/2.mp4)
![video 3](https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/3.mp4)
![video 4](https://raw.githubusercontent.com/GodzzZZZ/SourceRepository/master/MFPictureBrowser/4.mp4)

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
