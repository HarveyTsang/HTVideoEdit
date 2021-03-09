//
//  HTTimeRangeView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTimeRangeView.h"

@interface HTTimeRangeViewSideBarLayer : CALayer

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) UIRectCorner rectCorner;
@property (nonatomic, assign) BOOL isHighlight;

@end

@implementation HTTimeRangeViewSideBarLayer

- (instancetype)initWithRectCorner:(UIRectCorner)rectCorner {
    if (self = [super init]) {
        _rectCorner = rectCorner;
    }
    return self;
}

- (void)setColor:(UIColor *)color {
    _color = color;
    [self setNeedsDisplay];
}

- (void)setIsHighlight:(BOOL)isHighlight {
    if (_isHighlight != isHighlight) {
        _isHighlight = isHighlight;
        [self setNeedsDisplay];
    }
}

- (void)drawInContext:(CGContextRef)ctx {
    // 画圆角
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) byRoundingCorners:self.rectCorner cornerRadii:CGSizeMake(3.0, 3.0)];
    CGContextSetFillColorWithColor(ctx, self.color.CGColor);
    CGContextAddPath(ctx, path.CGPath);
    CGContextFillPath(ctx);
    
    // 画白色竖线
    CGFloat whiteLineLength = 16.0;
    CGFloat startY = (self.frame.size.height-whiteLineLength)/2.0;
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(5.0, startY, 2.0, whiteLineLength) byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(1.0, 1.0)];
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextAddPath(ctx, linePath.CGPath);
    CGContextFillPath(ctx);
    
    // 加高亮
    if (_isHighlight) {
        CGContextSetFillColorWithColor(ctx, [UIColor colorWithWhite:0.0 alpha:0.5].CGColor);
        CGContextAddPath(ctx, path.CGPath);
        CGContextFillPath(ctx);
    }
}

@end


@interface HTTimeRangeView ()

@property (nonatomic, strong) HTTimeRangeViewSideBarLayer *leftSideBar;
@property (nonatomic, strong) HTTimeRangeViewSideBarLayer *rightSideBar;

@end

@implementation HTTimeRangeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.layer.cornerRadius = 3;
        self.layer.masksToBounds = YES;
        [self setupSideBar];
    }
    return self;
}
- (void)setupSideBar {
    _leftSideBar = [[HTTimeRangeViewSideBarLayer alloc] initWithRectCorner:UIRectCornerTopLeft | UIRectCornerBottomLeft];
    _leftSideBar.contentsScale = [UIScreen mainScreen].scale;
    _leftSideBar.color = self.color;
    _leftSideBar.frame = CGRectMake(0, 0, 12.0, self.frame.size.height);
    [self.layer addSublayer:_leftSideBar];
    
    _rightSideBar = [[HTTimeRangeViewSideBarLayer alloc] initWithRectCorner:UIRectCornerTopRight | UIRectCornerBottomRight];
    _rightSideBar.contentsScale = [UIScreen mainScreen].scale;
    _rightSideBar.color = self.color;
    _rightSideBar.frame = CGRectMake(self.frame.size.width-12.0, 0, 12.0, self.frame.size.height);
    [self.layer addSublayer:_rightSideBar];
}

- (KKTimeRangeViewTouchPosition)touchPositionWithPoint:(CGPoint)point {
    CGRect leftRect = CGRectInset(CGRectMake(0, 0, 12.0, self.frame.size.height), -4, 0);
    if (CGRectContainsPoint(leftRect, point)) return KKTimeRangeViewTouchPositionLeft;
    
    CGRect rightRect = CGRectInset(CGRectMake(self.frame.size.width-12.0, 0, 12.0, self.frame.size.height), -4, 0);
    if (CGRectContainsPoint(rightRect, point)) return KKTimeRangeViewTouchPositionRight;
    
    return KKTimeRangeViewTouchPositionNone;
}

- (void)touchWithLocation:(CGPoint)location {
    self.currentTouchPosition = [self touchPositionWithPoint:location];
}

- (BOOL)isOutRangeWithPoint:(CGPoint)point {
    return CGRectContainsPoint(CGRectInset(self.bounds, -4, 0), point);
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)setColor:(UIColor *)color {
    _color = color;
    _leftSideBar.color = color;
    _rightSideBar.color = color;
    self.backgroundColor = [color colorWithAlphaComponent:0.3];
    [self setNeedsDisplay];
}

- (void)setCurrentTouchPosition:(KKTimeRangeViewTouchPosition)currentTouchPosition {
    _leftSideBar.isHighlight = currentTouchPosition == KKTimeRangeViewTouchPositionLeft;
    _rightSideBar.isHighlight = currentTouchPosition == KKTimeRangeViewTouchPositionRight;
    _currentTouchPosition = currentTouchPosition;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _leftSideBar.frame = CGRectMake(0, 0, 12.0, self.frame.size.height);
    _rightSideBar.frame = CGRectMake(self.frame.size.width-12.0, 0, 12.0, self.frame.size.height);
    [CATransaction commit];
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGFloat lineWidth = 2.0;
    CGFloat sideBarWidth = 12.0;
    // 画顶部、底部横线
    CGContextSetLineWidth(context, lineWidth);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    CGFloat offsetY = lineWidth/2.0;
    CGContextMoveToPoint(context, sideBarWidth, offsetY);
    CGContextAddLineToPoint(context, rect.size.width-sideBarWidth, offsetY);
    CGContextMoveToPoint(context, sideBarWidth, rect.size.height-offsetY);
    CGContextAddLineToPoint(context, rect.size.width-sideBarWidth, rect.size.height-offsetY);
    CGContextStrokePath(context);
}

@end
