//
//  UIApplication+Extension.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/1.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "UIApplication+Extension.h"

@implementation UIApplication (Extension)

- (UIViewController *)ht_topViewController {
    UIViewController *resultVC;
    resultVC = [self _ht_topViewController:[[UIApplication sharedApplication].keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _ht_topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_ht_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _ht_topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _ht_topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

@end
