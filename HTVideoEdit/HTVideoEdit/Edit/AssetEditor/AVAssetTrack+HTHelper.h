//
//  AVAssetTrack+HTHelper.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HTVideoRotation) {
    HTVideoRotation0,
    HTVideoRotation90,
    HTVideoRotation180,
    HTVideoRotation270,
};

@interface AVAssetTrack (HTHelper)

/// 返回视频轨的宽高
- (CGSize)ht_renderSize;

/// 返回视频轨的方向
- (HTVideoRotation)ht_rotation;

- (CGAffineTransform)ht_transform;

/// 类似UIViewContentModeScaleAspectFit
- (CGAffineTransform)ht_transformFitBox:(CGSize)boxSize;

/// 类似UIViewContentModeScaleAspectFill
- (CGAffineTransform)ht_transformFillBox:(CGSize)boxSize;

@end

NS_ASSUME_NONNULL_END
