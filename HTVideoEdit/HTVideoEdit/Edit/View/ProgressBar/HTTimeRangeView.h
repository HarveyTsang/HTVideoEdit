//
//  HTTimeRangeView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, KKTimeRangeViewTouchPosition) {
    KKTimeRangeViewTouchPositionNone,
    KKTimeRangeViewTouchPositionLeft,
    KKTimeRangeViewTouchPositionRight,
};

NS_ASSUME_NONNULL_BEGIN

@interface HTTimeRangeView : UIView

@property (nonatomic, strong) UIColor *color;

@property (nonatomic, assign) KKTimeRangeViewTouchPosition currentTouchPosition;

- (KKTimeRangeViewTouchPosition)touchPositionWithPoint:(CGPoint)point;
- (void)touchWithLocation:(CGPoint)location;
- (BOOL)isOutRangeWithPoint:(CGPoint)point;

@end

NS_ASSUME_NONNULL_END
