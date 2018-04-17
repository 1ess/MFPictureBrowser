//
//  MFCookiesManager.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "MFCookiesManager.h"
static NSString *cookies = @"cookies";
@implementation MFCookiesManager
+ (void)saveCookies {
    NSData *cookiesData = [NSKeyedArchiver archivedDataWithRootObject:[[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:cookiesData forKey:cookies];
    [defaults synchronize];
}
+ (void)loadCookiesWithName:(NSString *)cookiesName {
    NSArray *cookieList = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:cookies]];
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in cookieList){
        if ([cookie.name isEqualToString:cookiesName]) {
            [cookieStorage setCookie:cookie];
        }
    }
}
@end
