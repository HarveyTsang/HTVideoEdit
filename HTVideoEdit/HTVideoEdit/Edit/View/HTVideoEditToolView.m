//
//  HTVideoEditToolView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTVideoEditToolView.h"
#import "HTTextStickerAttributePicker.h"
#import "HTImagePicker.h"
#import "HTTextStickerView.h"
#import "HTImageStickerView.h"

typedef NS_ENUM(NSUInteger, KKEditViewButtonType) {
    KKEditViewButtonTypeInsertVideo,
    KKEditViewButtonTypeRemoveVideo,
    KKEditViewButtonTypeAddText,
    KKEditViewButtonTypeAddImage,
};

@interface HTVideoEditToolView ()<HTTextStickerAttributePickerDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *editView;
@property (nonatomic, strong) NSArray<UIButton *> *editViewButtons;
@property (nonatomic, strong) HTStickerView *selectedSticker;
@property (nonatomic, strong) HTTextStickerAttributePicker *textStickerAttributePicker;
@property (nonatomic, strong) HTImagePicker *imagePicker;

@end

@implementation HTVideoEditToolView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    [self addSubview:self.topView];
    [_topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.equalTo(self);
        make.height.equalTo(@40);
    }];
    [self addSubview:self.editView];
    [_editView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self);
        make.top.equalTo(self.topView.mas_bottom);
    }];
}

- (void)selectSticker:(HTStickerView *)sticker {
    _selectedSticker = sticker;
    if (!sticker) {
        _textStickerAttributePicker.hidden = YES;
        _imagePicker.hidden = YES;
        return;
    }
    if ([sticker isKindOfClass:HTTextStickerView.class]) {
        HTTextStickerView *textSticker = (HTTextStickerView *)sticker;
        self.textStickerAttributePicker.color = textSticker.textColor;
        self.textStickerAttributePicker.fontName = textSticker.fontName;
        self.textStickerAttributePicker.hidden = NO;
        _imagePicker.hidden = YES;
    } else if ([sticker isKindOfClass:HTImageStickerView.class]) {
        HTImageStickerView *imageSticker = (HTImageStickerView *)sticker;
        self.imagePicker.URL = imageSticker.URL;
        self.imagePicker.hidden = NO;
        _textStickerAttributePicker.hidden = YES;
    }
    
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor ht_primaryColor];
        
        UIColor *lineColor = [UIColor ht_lineColor];
        UIView *topLine = [UIView new];
        topLine.backgroundColor = lineColor;
        [_topView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(_topView);
            make.height.equalTo(@0.5);
        }];
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = lineColor;
        [_topView addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.equalTo(_topView);
            make.height.equalTo(@0.5);
        }];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:@"剪辑" forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:16];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor ht_selectedColor] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(topButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:button];
        
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.centerX.equalTo(_topView);
            make.width.mas_equalTo(100);
        }];
    }
    return _topView;
}

- (UIView *)editView {
    if (!_editView) {
        _editView = [UIView new];
        _editView.backgroundColor = [UIColor ht_primaryColor];
        NSArray *titles = @[@"插入", @"删除", @"文字", @"贴纸"];
        NSMutableArray *array = @[].mutableCopy;
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [btn setTitle:titles[i] forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
            [btn setTitleColor:UIColor.grayColor forState:UIControlStateDisabled];
            [btn addTarget:self action:@selector(editViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = 100+i;
            [_editView addSubview:btn];
            [array addObject:btn];
        }
        [array mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedItemLength:50 leadSpacing:30 tailSpacing:30];
        [array mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_editView);
            make.height.mas_equalTo(40);
        }];
        _editViewButtons = array;
    }
    return _editView;
}

- (HTTextStickerAttributePicker *)textStickerAttributePicker {
    if (!_textStickerAttributePicker) {
        _textStickerAttributePicker = [[HTTextStickerAttributePicker alloc] initWithFrame:self.bounds];
        _textStickerAttributePicker.delegate = self;
        [self addSubview:_textStickerAttributePicker];
    }
    return _textStickerAttributePicker;
}

- (HTImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[HTImagePicker alloc] initWithFrame:self.bounds];
        __weak typeof(self) ws = self;
        _imagePicker.didSelect = ^(NSURL * _Nonnull url) {
            if ([ws.delegate respondsToSelector:@selector(videoEditToolView:didSelectImage:)]) {
                [ws.delegate videoEditToolView:ws didSelectImage:url];
            }
        };
        _imagePicker.didClickClose = ^(HTImagePicker * _Nonnull picker) {
            picker.hidden = YES;
            if (ws.selectedSticker && [ws.delegate respondsToSelector:@selector(videoEditToolView:didCancelSelectSticker:)]) {
                [ws.delegate videoEditToolView:ws didCancelSelectSticker:ws.selectedSticker];
                ws.selectedSticker = nil;
            }
        };
        [self addSubview:_imagePicker];
    }
    return _imagePicker;
}

#pragma mark - Setter
- (void)setEnableInsertVideo:(BOOL)enableInsertVideo {
    _enableInsertVideo = enableInsertVideo;
    _editViewButtons[KKEditViewButtonTypeInsertVideo].enabled = enableInsertVideo;
}
- (void)setEnableRemoveVideo:(BOOL)enableRemoveVideo {
    _enableRemoveVideo = enableRemoveVideo;
    _editViewButtons[KKEditViewButtonTypeRemoveVideo].enabled = enableRemoveVideo;
}
- (void)setEnableAddSticker:(BOOL)enableAddSticker {
    _enableAddSticker = enableAddSticker;
    _editViewButtons[KKEditViewButtonTypeAddText].enabled = enableAddSticker;
    _editViewButtons[KKEditViewButtonTypeAddImage].enabled = enableAddSticker;
}

#pragma mark - Actions
- (void)topButtonAction:(UIButton *)sender {
    
}
- (void)editViewButtonAction:(UIButton *)sender {
    KKEditViewButtonType type = sender.tag-100;
    switch (type) {
        case KKEditViewButtonTypeInsertVideo: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoEditToolViewDidClickInsertVideo:)]) {
                [self.delegate videoEditToolViewDidClickInsertVideo:self];
            }
        }
            break;
        case KKEditViewButtonTypeRemoveVideo: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoEditToolViewDidClickRemoveVideo:)]) {
                [self.delegate videoEditToolViewDidClickRemoveVideo:self];
            }
        }
            break;
        case KKEditViewButtonTypeAddText: {
            if (self.delegate && [self.delegate respondsToSelector:@selector(videoEditToolViewDidClickAddText:)]) {
                [self.delegate videoEditToolViewDidClickAddText:self];
            }
        }
            break;
        case KKEditViewButtonTypeAddImage: {
            self.imagePicker.URL = nil;
            self.imagePicker.hidden = NO;
        }
            break;
    }
}


- (UIButton *)editButtonWithTitle:(NSString *)title {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    return button;
}

#pragma mark - HTTextStickerAttributePickerDelegate
- (void)textStickerAttributePicker:(HTTextStickerAttributePicker *)picker didSelectColor:(UIColor *)color {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoEditToolView:didSelectColor:)]) {
        [self.delegate videoEditToolView:self didSelectColor:color];
    }
}
- (void)textStickerAttributePicker:(HTTextStickerAttributePicker *)picker didSelectFont:(NSString *)fontName {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoEditToolView:didSelectFont:)]) {
        [self.delegate videoEditToolView:self didSelectFont:fontName];
    }
}

@end
