//
//  HTAssetSegment.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTAssetSegment.h"

@interface HTAssetSegment ()

@end

@implementation HTAssetSegment

- (instancetype)initWithAsset:(AVAsset *)asset
               assetTimeRange:(CMTimeRange)assetTimeRange
                  maxDuration:(CMTime)maxDuration
                   videoTrack:(HTTrackSegment *)videoTrack
                   audioTrack:(HTTrackSegment *_Nullable)audioTrack {
    if (self = [super init]) {
        _asset = asset;
        _assetTimeRange = assetTimeRange;
        _maxDuration = maxDuration;
        _videoTrack = videoTrack;
        _audioTrack = audioTrack;
    }
    return self;
}

- (void)updateAssetTimeRange:(CMTimeRange)timeRange withInsertTime:(CMTime)insertTime {
    if (CMTimeCompare(timeRange.start, kCMTimeZero) < 0 || CMTimeCompare(timeRange.duration, _maxDuration) > 0) return;
    
    if (_videoTrack) {
        [_videoTrack.compositionTrack removeTimeRange:CMTimeRangeMake(insertTime, _assetTimeRange.duration)];
        [_videoTrack.compositionTrack insertTimeRange:timeRange ofTrack:_videoTrack.assetTrack atTime:insertTime error:nil];
    }
    if (_audioTrack) {
        [_audioTrack.compositionTrack removeTimeRange:CMTimeRangeMake(insertTime, _assetTimeRange.duration)];
        [_audioTrack.compositionTrack insertTimeRange:timeRange ofTrack:_audioTrack.assetTrack atTime:insertTime error:nil];
    }
    _assetTimeRange = timeRange;
}

@end
