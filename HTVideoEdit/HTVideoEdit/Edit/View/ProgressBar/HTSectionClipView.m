//
//  HTSectionClipView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTSectionClipView.h"
#import "HTTimeRangeView.h"

@interface HTSectionClipView ()

@property (nonatomic, assign) CGFloat totalLength;

@end

@implementation HTSectionClipView

- (instancetype)initWithTotalLength:(CGFloat)totalLength {
    if (self = [super init]) {
        _totalLength = totalLength;
        _selected = NO;
        _contentView = [UIView new];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!_selected && (self.contentView.layer.mask == nil) ) {
        [self addMask:YES];
    }
    self.contentView.frame = self.bounds;
    if (_timeRangeView) _timeRangeView.frame = CGRectInset(self.bounds, -12, -2);
}
#pragma mark - Setter
- (void)setSelected:(BOOL)selected {
    if (_selected != selected) {
        _selected = selected;
        [self addMask: !_selected];
        self.timeRangeView.hidden = !_selected;
    }
}


#pragma mark - Getter

- (HTTimeRangeView *)timeRangeView {
    if (!_timeRangeView) {
        _timeRangeView = [[HTTimeRangeView alloc] initWithFrame:CGRectInset(self.bounds, -12, -2)];
        _timeRangeView.color = [UIColor ht_colorWithHexString:@"20A0FF"];
        [self addSubview:_timeRangeView];
    }
    return _timeRangeView;
}

#pragma mark - Public
- (NSRange)visualRangeWithRect:(CGRect)rect {
    CGFloat completeFrameX = self.frame.origin.x-self.visualRange.start;
    NSUInteger loc = (rect.origin.x - completeFrameX) / self.itemWidth;
    CGFloat end = (rect.origin.x - completeFrameX + rect.size.width) ;
    NSUInteger endIndex = end / self.itemWidth;
    if (endIndex * self.itemWidth == end) endIndex--;
    
    return NSMakeRange(loc, endIndex-loc+1);
}

#pragma mark - Private
- (void)addMask:(BOOL)needAdd {
    if (self.bounds.size.width < 8 || self.bounds.size.height < 8) return;
    
    if (needAdd) {
        self.layer.masksToBounds = NO;
        
        CGRect rect = self.bounds;
        rect = CGRectInset(rect, 2.0, 0.0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:4];
        CAShapeLayer *mask = [CAShapeLayer layer];
        mask.path = path.CGPath;
        self.contentView.layer.mask = mask;
    } else {
        self.contentView.layer.mask = nil;
        self.contentView.layer.masksToBounds = YES;
    }
}

@end
