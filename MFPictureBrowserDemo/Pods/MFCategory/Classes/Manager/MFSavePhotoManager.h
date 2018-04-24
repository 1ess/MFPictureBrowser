//
//  MFSavePhotoManager.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef void (^successHandler)(void);
typedef void (^failureHandler)(NSError * _Nullable error);
@interface MFSavePhotoManager : NSObject
///保存普通类型的 image eg: png, jpg
+ (void)saveImage:(UIImage *_Nullable)image
          success:(successHandler _Nullable )successHandle
          failure:(failureHandler _Nullable )failureHanlde;

///保存 gif 类型的图片. imageData 可从 SD 或 YY 框架的缓存数据获取
/*
 YYWebImageManager *manager = [YYWebImageManager sharedManager];
 NSString *key = [manager cacheKeyForURL:url];
 NSData *data = [manager.cache getImageDataForKey:key];
 */
+ (void)saveImageData:(NSData *_Nullable)imageData
              success:(successHandler _Nullable )successHandle
              failure:(failureHandler _Nullable )failureHanlde;
@end
