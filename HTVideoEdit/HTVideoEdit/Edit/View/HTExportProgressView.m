//
//  HTExportProgressView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/7.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTExportProgressView.h"

@interface HTExportProgressView ()

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, copy) HTExportProgressViewDidClickClose clickClose;

@end

@implementation HTExportProgressView

+ (instancetype)exportProgressViewWithCloseAction:(HTExportProgressViewDidClickClose)clickClose {
    HTExportProgressView *view = [[HTExportProgressView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.clickClose = clickClose;
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.8];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"edit_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.top.offset(60);
        make.leading.offset(20);
    }];
    
    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    _progressView.trackTintColor = UIColor.grayColor;
    [self addSubview:_progressView];
    [_progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.offset(0);
        make.width.equalTo(@200);
    }];
    
    _progressLabel = [[UILabel alloc] init];
    _progressLabel.textColor = UIColor.whiteColor;
    [self addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(_progressView.mas_top).offset(-30);
        make.centerX.offset(0);
    }];
    
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:activityIndicatorView];
    [activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_progressLabel);
        make.trailing.equalTo(_progressLabel.mas_leading).offset(-10);
    }];
    [activityIndicatorView startAnimating];
}

- (void)show {
    [UIApplication.sharedApplication.keyWindow addSubview:self];
}

- (void)dismiss {
    [self removeFromSuperview];
}

- (void)setProgress:(double)progress {
    _progress = MAX(MIN(progress, 1.0), 0.0);
    _progressLabel.text = [NSString stringWithFormat:@"%.1f%%", _progress*100.0];
    _progressView.progress = _progress;
}

- (void)closeBtnAction {
    if (self.clickClose) {
        self.clickClose();
    }
    [self dismiss];
}



@end
