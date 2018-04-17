//
//  MFREManager.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MFREManager : NSObject
//判断手机号码格式是否正确
+ (BOOL)valiMobile:(NSString *)mobile;
//利用正则表达式验证
+ (BOOL)isAvailableEmail:(NSString *)email;
@end
