//
//  HTTextStickerView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTStickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTTextStickerView : HTStickerView

@property (nonatomic, copy) NSString *text;

@property (nonatomic, copy, nullable) NSString *fontName;

@property (nonatomic, strong) UIColor *textColor;

- (instancetype)initWithText:(NSString *)text;

- (void)update;

@end

NS_ASSUME_NONNULL_END
