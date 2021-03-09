//
//  HTStickerHighlightView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTStickerHighlightView.h"

NSString *const HTStickerHightlightViewActionTypeRemove = @"remove";
NSString *const HTStickerHightlightViewActionTypeEdit = @"edit";
NSString *const HTStickerHightlightViewActionTypeScaleAndRotate = @"scale_rotate";

static CGFloat const margin = 10;

@interface HTStickerHightlightActionView : UIView

@property (nonatomic, strong) NSString *type;

@end

@implementation HTStickerHightlightActionView

- (instancetype)initWithType:(NSString *)type imageName:(NSString *)imageName {
    if (self = [super init]) {
        _type = type;
        UIImageView *imageView = [UIImageView new];
        imageView.image = [UIImage imageNamed:imageName];
        [self addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.offset(0);
            make.width.height.equalTo(@15);
        }];
        self.backgroundColor = [UIColor ht_selectedColor];
        self.layer.cornerRadius = margin;
    }
    return self;
}

@end

@interface HTStickerHighlightView ()

@property (nonatomic, strong) NSMutableArray<HTStickerHightlightActionView *> *currentActionViews;
@property (nonatomic, strong) NSArray<UIImageView *> *lines;

@end

@implementation HTStickerHighlightView

- (instancetype)initWithActionTypes:(NSArray<NSString *> *)actionTypes {
    if (self = [super init]) {
        [self setupFrameLines];
        _currentActionViews = @[].mutableCopy;
        NSArray *types = @[
            HTStickerHightlightViewActionTypeRemove,
            HTStickerHightlightViewActionTypeEdit,
            HTStickerHightlightViewActionTypeScaleAndRotate,
        ];
        NSArray *imageNames = @[
            @"edit_sticker_remove_btn",
            @"edit_sticker_input_btn",
            @"edit_sticker_scale_btn",
        ];
        NSUInteger count = MIN(4, actionTypes.count);
        for (int i = 0; i < count; i++) {
            NSString *type = actionTypes[i];
            NSUInteger index = [types indexOfObject:type];
            if (index != NSNotFound) {
                HTStickerHightlightActionView *actionView = [[HTStickerHightlightActionView alloc] initWithType:type imageName:imageNames[index]];
                [self addSubview:actionView];
                [_currentActionViews addObject:actionView];
            }
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateSubviewsFrame];
}

- (void)setupFrameLines {
    NSMutableArray *array = @[].mutableCopy;
    for (int i = 0; i < 4; i++) {
        UIImageView *line = [UIImageView new];
        line.image = [self lineImageWithIsVertical:i%2];
        [self addSubview:line];
        [array addObject:line];
    }
    self.lines = array.copy;// 上、左、下、右
}
- (UIImage *)lineImageWithIsVertical:(BOOL)isVertical {
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = [UIColor clearColor];
    UIView *point = [[UIView alloc] init];
    point.backgroundColor = [UIColor whiteColor];
    [background addSubview:point];
    if (isVertical) {
        background.frame = CGRectMake(0, 0, 5, 1);
        point.frame = CGRectMake(2, 0, 1, 1);
    }
    else {
        background.frame = CGRectMake(0, 0, 1, 5);
        point.frame = CGRectMake(0, 2, 1, 1);
    }
    
    UIGraphicsBeginImageContextWithOptions(background.frame.size, NO, [UIScreen mainScreen].scale);
    [background.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIView *)createContainerView {
    UIView *v = [UIView new];
    [self addSubview:v];
    v.backgroundColor = [UIColor clearColor];
    return v;
}

- (void)updateSubviewsFrame {
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    CGFloat w = 2*margin;
    CGRect actionViewFrames[4] = {
        CGRectMake(-margin, -margin, w, w),
        CGRectMake(width-margin, -margin, w, w),
        CGRectMake(width-margin, height-margin, w, w),
        CGRectMake(-margin, height-margin, w, w)
    };
    for (int i = 0; i < _currentActionViews.count; i++) {
        HTStickerHightlightActionView *actionView = _currentActionViews[i];
        actionView.frame = actionViewFrames[i];
    }
    CGRect lineFrames[4] = {
        CGRectMake(0, -2, width, 5), // 上
        CGRectMake(-2, 0, 5, height),// 左
        CGRectMake(0, height-3, width, 5),// 下
        CGRectMake(width-3, 0, 5, height),// 右
    };
    for (int i = 0; i < 4; i++) {
        self.lines[i].frame = lineFrames[i];
    }
}
- (void)clearAllActionViews {
    for (HTStickerHightlightActionView *actionView in _currentActionViews) {
        [actionView removeFromSuperview];
    }
    [_currentActionViews removeAllObjects];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    CGRect relativeFrame = self.bounds;
    CGRect hitFrame = UIEdgeInsetsInsetRect(relativeFrame, UIEdgeInsetsMake(-margin*2, -margin*2, -margin*2, -margin*2));
    
    return CGRectContainsPoint(hitFrame, point);
}

- (NSString *)actionTypeAtClickPoint:(CGPoint)point {
    for (HTStickerHightlightActionView *actionView in self.currentActionViews) {
        CGRect frame = CGRectInset(actionView.frame, -10, -10);
        if (CGRectContainsPoint(frame, point)) {
            return actionView.type;
        }
    }
    return nil;
}

- (void)touchWithPoint:(CGPoint)point {
    _currentActionType = [self actionTypeAtClickPoint:point];
}

@end
