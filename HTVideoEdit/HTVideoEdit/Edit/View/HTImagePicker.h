//
//  HTImagePicker.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/6.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTImagePicker;
typedef void(^HTImagePickerSelect)(NSURL *url);
typedef void(^HTImagePickerClose)(HTImagePicker *picker);

@interface HTImagePicker : UIView

@property (nonatomic, strong, nullable) NSURL *URL;

@property (nonatomic, copy, nullable) HTImagePickerSelect didSelect;

@property (nonatomic, copy, nullable) HTImagePickerClose didClickClose;

@end

NS_ASSUME_NONNULL_END
