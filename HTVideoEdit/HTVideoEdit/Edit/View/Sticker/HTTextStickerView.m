//
//  HTTextStickerView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTextStickerView.h"

@interface HTTextStickerView ()

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) UIImageView *textImageView;

@end

@implementation HTTextStickerView

- (instancetype)initWithText:(NSString *)text {
    UIFont *font = [UIFont systemFontOfSize:20];
    CGSize textSize = [text sizeWithAttributes:@{NSFontAttributeName:font}];
    if (self = [super initWithFrame:CGRectMake(0, 0, textSize.width, textSize.height)]) {
        _text = text;
        _textColor = UIColor.blackColor;
        _textImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [self addSubview:_textImageView];
        [self updateWithFont:font];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _textImageView.frame = self.bounds;
}

- (void)setText:(NSString *)text {
    _text = text;
    [self updateWithFont:self.label.font];
}

- (void)setFontName:(NSString *)fontName {
    _fontName = fontName;
    [self updateWithFont:[UIFont fontWithName:fontName size:self.label.font.pointSize]];
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    [self updateWithFont:self.label.font];
}

- (void)update {
    [self updateWithFont:nil];
}

- (void)updateWithFont:(UIFont *)font {
    self.label.text = self.text;
    self.label.textColor = self.textColor;
    if (font) {
        CGSize size = [self.text sizeWithAttributes:@{NSFontAttributeName:font}];
        self.bounds = CGRectMake(0, 0, size.width, size.height);
        _textImageView.frame = self.bounds;
        self.label.font = font;
    } else {
        self.label.font = [self fontFitSize:self.bounds.size andText:self.text withFontName:self.fontName];
    }
    self.label.frame = _textImageView.frame;
    UIImage *img = [self imageFromLabel:self.label];
    _textImageView.image = img;
}

- (UIFont *)fontFitSize:(CGSize)size andText:(NSString *)text withFontName:(NSString *)fontName {
    UIFont *unadjustedFont = nil;
    if (fontName) {
        unadjustedFont = [UIFont fontWithName:fontName size:size.height];
    } else {
        unadjustedFont = [UIFont systemFontOfSize:size.height];
    }
    CGSize unadjustedSize = [text sizeWithAttributes:@{NSFontAttributeName:unadjustedFont}];
    CGFloat scaleFactor = size.width / unadjustedSize.width;
    CGFloat newFontSize = floor(unadjustedFont.pointSize * scaleFactor);
    if (fontName) {
        return [UIFont fontWithName:fontName size:newFontSize];
    }
    return [UIFont systemFontOfSize:newFontSize];
}

- (UIImage *)imageFromLabel:(UILabel *)label {
    if (CGSizeEqualToSize(label.frame.size, CGSizeZero)) return nil;
    
    UIGraphicsBeginImageContextWithOptions(label.frame.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [label.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UILabel *)label {
    if (!_label) {
        UILabel *label = [UILabel new];
        label.frame = _textImageView.frame;
        label.text = self.text;
        label.textColor = self.textColor;
        label.textAlignment = NSTextAlignmentCenter;
        label.numberOfLines = 0;
        label.adjustsFontSizeToFitWidth = YES;// 避免截断
        _label = label;
    }
    return _label;
}

- (NSArray<NSString *> *)actionTypes {
    return @[
        HTStickerHightlightViewActionTypeRemove,
        HTStickerHightlightViewActionTypeEdit,
        HTStickerHightlightViewActionTypeScaleAndRotate,
    ];
}

- (CALayer *)layerWithScale:(CGFloat)scale {
    CALayer *layer = [super layerWithScale:scale];
    
    CGFloat totalHeight = layer.frame.size.height;
    CALayer *textLayer = [CALayer new];
    CGRect textFrame = HTRectMultiplyScale(_textImageView.frame, scale);
    textFrame.origin.y = totalHeight-textFrame.size.height-textFrame.origin.y;
    textLayer.frame = textFrame;
    textLayer.contents = (__bridge id)_textImageView.image.CGImage;
    [layer addSublayer:textLayer];
    
    return layer;
}

@end
