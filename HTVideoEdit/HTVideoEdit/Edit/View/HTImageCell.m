//
//  HTImageCell.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/6.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTImageCell.h"

@implementation HTImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.layer.cornerRadius = 8;
        _imageView.layer.borderColor = [UIColor ht_selectedColor].CGColor;
        _imageView.layer.borderWidth = 0;
        [self.contentView addSubview:_imageView];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _imageView.layer.borderWidth = selected ? 3 : 0;
}

@end
