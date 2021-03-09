//
//  HTFontCell.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/4.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTFontCell.h"

@interface HTFontCell ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *downloadIconView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong) UILabel *progressLabel;

@end

@implementation HTFontCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    _downloadIconView = [UIImageView new];
    _downloadIconView.image = [UIImage imageNamed:@"edit_cloud_down"];
    [self.contentView addSubview:_downloadIconView];
    [_downloadIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@25);
        make.centerY.offset(0);
        make.trailing.offset(-5);
    }];
    
    _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self.contentView addSubview:_activityIndicatorView];
    [_activityIndicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_downloadIconView);
    }];
    [_activityIndicatorView startAnimating];
    
    _progressLabel = [UILabel new];
    _progressLabel.textColor = UIColor.whiteColor;
    _progressLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:_progressLabel];
    [_progressLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_downloadIconView);
    }];
    _progressLabel.text = @"0.0%";
    
    _imageView = [UIImageView new];
    _imageView.contentMode = UIViewContentModeScaleAspectFit;
    _imageView.image = [[UIImage imageNamed:@"Image002"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    _imageView.tintColor = [UIColor whiteColor];
    [self.contentView addSubview:_imageView];
    [_imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.top.offset(0);
        make.trailing.equalTo(_downloadIconView.mas_leading);
    }];
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    _imageView.tintColor = selected ? [UIColor ht_selectedColor] : UIColor.whiteColor;
}

- (void)setupWithFontInfo:(HTFontInfo *)fontInfo {
    _imageView.image = [[UIImage imageNamed:fontInfo.name] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self updateWithStatus:fontInfo.status];
    [self updateWithProgress:fontInfo.progress];
}

- (void)updateWithStatus:(HTFontStatus)status {
    _downloadIconView.hidden = (status != HTFontStatusInit &&
                                status != HTFontStatusDownloadFailed);
    _activityIndicatorView.hidden = status != HTFontStatusWaiting;
    _progressLabel.hidden = status != HTFontStatusDownloading;
}

- (void)updateWithProgress:(double)progress {
    _progressLabel.text = [NSString stringWithFormat:@"%0.1f%%", progress];
}

@end
