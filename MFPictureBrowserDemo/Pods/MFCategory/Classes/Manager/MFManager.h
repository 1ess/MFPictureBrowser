//
//  MFManager.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface MFManager : NSObject
+ (void)animatedTransferKeyWindow:(UIViewController *)controller;
+ (void)jumpAppStoreWithAppID:(NSString *)appID;
@end
