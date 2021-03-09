//
//  KKProgressBarMaskView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTimeRangeDragTrackView;
@protocol HTTimeRangeDragTrackViewDelegate <NSObject>

@optional
- (BOOL)dragTrackView:(HTTimeRangeDragTrackView *)view shouldTouchBeginAtPoint:(CGPoint)point;

- (void)dragTrackView:(HTTimeRangeDragTrackView *)view touchMove:(CGPoint)point;

- (void)touchEndDragTrackView:(HTTimeRangeDragTrackView *)view;

@end

@interface HTTimeRangeDragTrackView : UIView

@property (nonatomic, weak, nullable) id<HTTimeRangeDragTrackViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
