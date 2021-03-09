//
//  HTSectionClipViewDataSource.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVKit/AVKit.h>
#import "HTSectionClipScrollView.h"

#define kFrameDuration 1.0 // 1帧1秒
#define kPixelsSecond (40.0/kFrameDuration) // 像素/秒

NS_ASSUME_NONNULL_BEGIN

@interface HTSectionClipViewDataSource : NSObject

@property (nonatomic, assign) CMTimeRange trimTimeRange;

@property (nonatomic, readonly) CGFloat totalLength;

@property (nonatomic, readonly) HTSectionVisualRange visualRange;

- (instancetype)initWithAsset:(AVAsset *)asset;

- (void)queryImageAtIndex:(NSUInteger)index forImageView:(UIImageView *)imageView;

+ (CGSize)itemSize;

@end

NS_ASSUME_NONNULL_END
