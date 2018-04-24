//
//  NSString+File.h
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (File)
+ (instancetype)uuid;
+ (instancetype)documentPath;
+ (instancetype)homePath;
+ (instancetype)tempPath;
@end
