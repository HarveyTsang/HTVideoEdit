//
//  HTStickerView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTStickerView.h"
#import "HTStickerHighlightView.h"

CGRect HTRectMultiplyScale(CGRect rect, CGFloat scale) {
    CGRect newRect = rect;
    newRect.origin.x *= scale;
    newRect.origin.y *= scale;
    newRect.size.height *= scale;
    newRect.size.width *= scale;
    return newRect;
}

double const kMinStickerDurationSeconds = 0.5;

@interface HTStickerView ()

@property (nonatomic, strong) HTStickerHighlightView *highlightView;

@end

@implementation HTStickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _timeRange = kCMTimeRangeInvalid;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_highlightView) _highlightView.frame = self.bounds;
}

- (CALayer *)layerWithScale:(CGFloat)scale {
    CALayer *layer = [CALayer new];
    CGRect frame = self.bounds;
    CGPoint center = self.center;
    frame.origin.x = center.x - frame.size.width/2.0;
    frame.origin.y = center.y - frame.size.height/2.0;
    layer.frame = HTRectMultiplyScale(frame, scale);
    return layer;
}

- (UIView *)highlightView {
    if (!_highlightView) {
        _highlightView = [[HTStickerHighlightView alloc] initWithActionTypes:self.actionTypes];
        _highlightView.backgroundColor = [UIColor clearColor];
        [self addSubview:_highlightView];
    }
    return _highlightView;
}

- (NSArray<NSString *> *)actionTypes {
    return @[HTStickerHightlightViewActionTypeRemove];
}

- (void)touchWithPoint:(CGPoint)point {
    CGPoint locationInHighlightView = [self convertPoint:point toView:_highlightView];
    [_highlightView touchWithPoint:locationInHighlightView];
}

- (NSString *)highlightViewActionType {
    return _highlightView.currentActionType;
}

- (CGPoint)locationOfScaleAndRotateActionView {
    NSUInteger index = [self.actionTypes indexOfObject:HTStickerHightlightViewActionTypeScaleAndRotate];
    if (index == NSNotFound){
        return CGPointZero;
    }
    CGFloat w = self.bounds.size.width;
    CGFloat h = self.bounds.size.height;
    switch (index) {
        case 0:
            return CGPointMake(-w/2, -h/2);
        case 1:
            return CGPointMake(w/2, -h/2);
        case 2:
            return CGPointMake(w/2, h/2);
        case 3:
            return CGPointMake(-w/2, h/2);
        default:
            return CGPointZero;
    }
}

- (void)setSelected:(BOOL)selected {
    self.highlightView.hidden = !selected;
}

@end
