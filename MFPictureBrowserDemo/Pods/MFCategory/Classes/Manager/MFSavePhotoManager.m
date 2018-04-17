//
//  MFSavePhotoManager.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "MFSavePhotoManager.h"
#import <Photos/Photos.h>
@implementation MFSavePhotoManager
+ (void)saveImage:(UIImage *)image
          success:(successHandler)successHandle
          failure:(failureHandler)failureHanlde {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            [PHAssetChangeRequest creationRequestForAssetFromImage:image];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && successHandle) {
                successHandle();
            }else if (error && failureHanlde) {
                failureHanlde(error);
            }
        }];
    });
}

+ (void)saveImageData:(NSData *)imageData
              success:(successHandler)successHandle
              failure:(failureHandler)failureHanlde {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetResourceCreationOptions *options = [[PHAssetResourceCreationOptions alloc] init];
            [[PHAssetCreationRequest creationRequestForAsset] addResourceWithType:PHAssetResourceTypePhoto data:imageData options:options];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (success && successHandle) {
                successHandle();
            }else if (error && failureHanlde) {
                failureHanlde(error);      
            }
        }];
    });
}
@end
