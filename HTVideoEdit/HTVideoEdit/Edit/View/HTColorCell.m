//
//  HTColorCell.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/6.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTColorCell.h"

@interface HTColorCell ()

@property (nonatomic, strong) CALayer *borderLayer;

@end

@implementation HTColorCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}
- (void)setupSubviews {
    _colorView = [UIView new];
    _colorView.layer.cornerRadius = self.frame.size.width/2.0 - 3.0;
    _colorView.layer.masksToBounds = YES;
    [self.contentView addSubview:_colorView];
    [_colorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(3, 3, 3, 3));
    }];
}
- (CALayer *)borderLayer {
    if (!_borderLayer) {
        _borderLayer = [[CALayer alloc] init];
        _borderLayer.frame = self.bounds;
        _borderLayer.cornerRadius = self.bounds.size.width/2.0;
        _borderLayer.borderColor = [UIColor ht_selectedColor].CGColor;
        _borderLayer.borderWidth = 0.5;
        [self.contentView.layer insertSublayer:_borderLayer atIndex:0];
    }
    return _borderLayer;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.borderLayer.hidden = !selected;
}

@end
