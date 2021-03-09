//
//  KKProgressBarMaskView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTimeRangeDragTrackView.h"
#import "NSTimer+Weak.h"

@interface HTTimeRangeDragTrackView ()

@property (nonatomic, assign) BOOL shouldTrack;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, strong) NSValue *touchPoint;

@end

@implementation HTTimeRangeDragTrackView

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    if (self.delegate && [self.delegate respondsToSelector:@selector(dragTrackView:shouldTouchBeginAtPoint:)]) {
        CGPoint point = [touch locationInView:self];
        _touchPoint = [NSValue valueWithCGPoint:point];
        _shouldTrack = [self.delegate dragTrackView:self shouldTouchBeginAtPoint:point];
    }
    else {
        _shouldTrack = NO;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_shouldTrack) {
        UITouch *touch = [touches anyObject];
        CGPoint point = [touch locationInView:self];
        _touchPoint = [NSValue valueWithCGPoint:point];
        if (self.delegate && [self.delegate respondsToSelector:@selector(dragTrackView:touchMove:)]) {
            [self.delegate dragTrackView:self touchMove:point];
        }
        if (point.x < 60 || point.x > self.bounds.size.width-60) {
            if (!_isObserving) {
                [self observe];
            }
        } else {
            if (_isObserving) {
                [self cancelObserve];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (_shouldTrack) {
        _touchPoint = nil;
        if (self.delegate && [self.delegate respondsToSelector:@selector(touchEndDragTrackView:)]) {
            [self.delegate touchEndDragTrackView:self];
        }
    }
}

- (void)observe {
    _isObserving = YES;
    self.timer.fireDate = [NSDate distantPast];
}
- (void)cancelObserve {
    _isObserving = NO;
    self.timer.fireDate = [NSDate distantFuture];
}

- (NSTimer *)timer {
    if (!_timer) {
        __weak HTTimeRangeDragTrackView *ws = self;
        _timer = [NSTimer ht_timerWithTimeInterval:0.2 block:^{
            if (ws.touchPoint) {
                if (ws.delegate && [ws.delegate respondsToSelector:@selector(dragTrackView:touchMove:)]) {
                    [ws.delegate dragTrackView:ws touchMove:ws.touchPoint.CGPointValue];
                }
            }
        } repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
    return _timer;
}

@end
