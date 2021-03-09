//
//  HTAssetPickerController.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/1.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTAssetPickerController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIApplication+Extension.h"

@interface HTAssetPickerController ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) HTAssetPickerControllerVideoPickCompletion videoPickCompletion;

@end

@implementation HTAssetPickerController

+ (void)pickVideo:(HTAssetPickerControllerVideoPickCompletion)completion {
    if ([self isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum]) {
        HTAssetPickerController *vc = [[HTAssetPickerController alloc] init];
        vc.videoPickCompletion = completion;
        vc.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        vc.mediaTypes = @[(NSString *)kUTTypeMovie];
        vc.delegate = vc;
        UIViewController *topVC = [UIApplication.sharedApplication ht_topViewController];
        [topVC presentViewController:vc animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info {
    if (self.videoPickCompletion) {
        NSURL *url = info[UIImagePickerControllerMediaURL];
        AVAsset *asset = [AVURLAsset assetWithURL:url];
        self.videoPickCompletion(asset);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
