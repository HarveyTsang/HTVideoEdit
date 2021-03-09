//
//  HTStickerView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HTStickerHighlightView.h"

NS_ASSUME_NONNULL_BEGIN

extern CGRect HTRectMultiplyScale(CGRect rect, CGFloat scale);

@interface HTStickerView : UIView

@property (nonatomic, assign) CMTimeRange timeRange;

@property (nonatomic, assign) BOOL selected;

- (CALayer *)layerWithScale:(CGFloat)scale;

- (NSArray<NSString *> *)actionTypes;

- (void)touchWithPoint:(CGPoint)point;

- (NSString *_Nullable)highlightViewActionType;

- (CGPoint)locationOfScaleAndRotateActionView;

@end

NS_ASSUME_NONNULL_END
