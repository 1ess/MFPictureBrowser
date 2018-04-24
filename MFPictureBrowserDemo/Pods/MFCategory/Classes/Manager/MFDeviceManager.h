//
//  MFDeviceManager.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MFDeviceManager : NSObject
//Screen scale
+ (CGFloat)scale;
//生成GUID
+ (NSString *)guid;
//磁盘全部空间
+ (CGFloat)diskOfAllSizeGBytes;
//磁盘可用空间
+ (CGFloat)diskOfFreeSizeGBytes;
//获取文件大小
+ (long long)fileSizeAtPath:(NSString *)filePath;
//获取文件夹下所有文件的大小
+ (long long)folderSizeAtPath:(NSString *)folderPath;
//获取设备 IP 地址
+ (NSString *)getIPAddress;
@end
