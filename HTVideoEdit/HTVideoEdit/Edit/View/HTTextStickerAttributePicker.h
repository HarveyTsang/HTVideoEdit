//
//  HTTextStickerAttributePicker.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/3.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTextStickerAttributePicker;
@protocol HTTextStickerAttributePickerDelegate <NSObject>

@optional
- (void)textStickerAttributePicker:(HTTextStickerAttributePicker *)picker didSelectColor:(UIColor *)color;
- (void)textStickerAttributePicker:(HTTextStickerAttributePicker *)picker didSelectFont:(NSString *)fontName;

@end

@interface HTTextStickerAttributePicker : UIView

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, copy) NSString *fontName;

@property (nonatomic, weak, nullable) id<HTTextStickerAttributePickerDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
