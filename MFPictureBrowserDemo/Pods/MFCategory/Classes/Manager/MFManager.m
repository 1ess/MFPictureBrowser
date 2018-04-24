//
//  MFManager.m
//
//  Created by 张冬冬.
//  Copyright © 2018年 张冬冬. All rights reserved.
//

#import "MFManager.h"
@implementation MFManager

+ (void)animatedTransferKeyWindow:(UIViewController *)controller {
    [UIView transitionWithView:[UIApplication sharedApplication].keyWindow duration:0.3f options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        BOOL oldState = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        [UIApplication sharedApplication].keyWindow.rootViewController = controller;
        [UIView setAnimationsEnabled:oldState];
    } completion:nil];
}

+ (void)jumpAppStoreWithAppID:(NSString *)appID {
    NSString *urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appID];
    NSURL *url = [NSURL URLWithString:urlString];
    if (@available(iOS 10, *)) {
        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
    }else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
