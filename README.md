# MFPictureBrowser

类似于<即刻>应用的图片浏览器效果
[参考：ESPictureBrowser](https://github.com/EnjoySR/ESPictureBrowser), 提交了 PR, 但原作者可能不维护了, 所以我重新写了一下, 并修改了其中一些 bug.

## 效果图

<img src="https://github.com/GodzzZZZ/Warehouse/blob/master/MFPictureBrowser/1.gif" width="33%"/><img src="https://github.com/GodzzZZZ/Warehouse/blob/master/MFPictureBrowser/2.gif" width="33%"/><img src="https://github.com/GodzzZZZ/Warehouse/blob/master/MFPictureBrowser/3.gif" width="33%"/>

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
//必须实现
- (FLAnimatedImageView *)pictureView:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
    ...
}

- (id<MFPictureModelProtocol>)pictureBrowser:(MFPictureBrowser *)pictureBrowser pictureModelAtIndex:(NSInteger)index {
    ...
}
```

具体使用方式参见 Demo

