# MFPictureBrowser

类似于<即刻>应用的图片浏览器效果
参考：ESPictureBrowser

## 效果图

<img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/Snapshot/1.gif" width="50%"/><img src="https://github.com/GodzzZZZ/MFPictureBrowser/blob/master/Snapshot/2.gif" width="50%"/>

## 使用方式
- 导入

```
#import <MFPictureBrowser.h>
```

- 初始化并设置代理

```
MFPictureBrowser *brower = [[MFPictureBrowser alloc] init];
brower.delegate = self;
```
- 展示

```
[brower showFromView:(view) picturesCount:(count) currentPictureIndex:(index)];
```

- 实现代理方法

```
//必须实现
- (UIView *)pictureView:(MFPictureBrowser *)pictureBrowser imageViewAtIndex:(NSInteger)index {
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

