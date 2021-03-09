//
//  HTFontCell.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/4.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTFontInfo.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTFontCell : UICollectionViewCell

- (void)setupWithFontInfo:(HTFontInfo *)fontInfo;

- (void)updateWithStatus:(HTFontStatus)status;

- (void)updateWithProgress:(double)progress;

@end

NS_ASSUME_NONNULL_END
