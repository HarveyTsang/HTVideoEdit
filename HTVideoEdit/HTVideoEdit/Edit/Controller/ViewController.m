//
//  ViewController.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "ViewController.h"
#import "HTAssetPickerController.h"
#import "HTVideoEditViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)selectVideo:(UIButton *)sender {
    __weak typeof(self) ws = self;
    [HTAssetPickerController pickVideo:^(AVAsset * _Nullable asset) {
        if (!asset) return;
        HTVideoEditViewController *editVC = [[HTVideoEditViewController alloc] initWithAsset:asset];
        [ws.navigationController pushViewController:editVC animated:YES];
    }];
}


@end
