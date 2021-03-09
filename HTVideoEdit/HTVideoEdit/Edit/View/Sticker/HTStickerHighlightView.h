//
//  HTStickerHighlightView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const HTStickerHightlightViewActionTypeRemove;
extern NSString *const HTStickerHightlightViewActionTypeEdit;
extern NSString *const HTStickerHightlightViewActionTypeScaleAndRotate;

@interface HTStickerHighlightView : UIView

- (instancetype)initWithActionTypes:(NSArray<NSString *> *)actionTypes;

@property (nonatomic, assign) CGSize originalSize;

@property (nonatomic, strong, nullable) NSString *currentActionType;

- (void)touchWithPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
