//
//  HTAssetPickerController.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/1.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTAssetPickerControllerVideoPickCompletion)(AVAsset *_Nullable asset);

@interface HTAssetPickerController : UIImagePickerController

+ (void)pickVideo:(HTAssetPickerControllerVideoPickCompletion)completion;

@end

NS_ASSUME_NONNULL_END
