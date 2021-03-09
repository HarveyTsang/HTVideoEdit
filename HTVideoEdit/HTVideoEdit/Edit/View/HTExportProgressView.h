//
//  HTExportProgressView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/7.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTExportProgressViewDidClickClose)(void);

@interface HTExportProgressView : UIView

@property (nonatomic, assign) double progress;// 0.0~1.0

+ (instancetype)exportProgressViewWithCloseAction:(HTExportProgressViewDidClickClose)clickClose;

- (void)show;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
