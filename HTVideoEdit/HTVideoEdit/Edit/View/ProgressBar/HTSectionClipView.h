//
//  HTSectionClipView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTSectionClipScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTSectionClipView : UIView

@property (nonatomic, assign) CGFloat itemWidth;
@property (nonatomic, assign) HTSectionVisualRange visualRange;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) HTTimeRangeView *timeRangeView;
@property (nonatomic, assign) BOOL selected;

- (instancetype)initWithTotalLength:(CGFloat)totalLength;

- (NSRange)visualRangeWithRect:(CGRect)rect;// rect 以scrollview为参考系

@end

NS_ASSUME_NONNULL_END
