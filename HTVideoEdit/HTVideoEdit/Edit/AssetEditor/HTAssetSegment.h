//
//  HTAssetSegment.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTrackSegment.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTAssetSegment : NSObject

@property (nonatomic, strong, readonly) HTTrackSegment *videoTrack;
@property (nonatomic, strong, readonly) HTTrackSegment *audioTrack;
@property (nonatomic, assign, readonly) CMTimeRange assetTimeRange;
@property (nonatomic, assign, readonly) CMTime maxDuration;
@property (nonatomic, strong, readonly) AVAsset *asset;

- (instancetype)initWithAsset:(AVAsset *)asset
               assetTimeRange:(CMTimeRange)assetTimeRange
                  maxDuration:(CMTime)maxDuration
                   videoTrack:(HTTrackSegment *)videoTrack
                   audioTrack:(HTTrackSegment *_Nullable)audioTrack;

- (void)updateAssetTimeRange:(CMTimeRange)timeRange withInsertTime:(CMTime)insertTime;

@end

NS_ASSUME_NONNULL_END
