//
//  HTTrackSegment.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTrackSegment : NSObject

@property (nonatomic, strong) AVAssetTrack *assetTrack;

@property (nonatomic, strong) AVMutableCompositionTrack *compositionTrack;

@property (nonatomic, assign) CMTimeRange timeRange;

@property (nonatomic, assign) CGAffineTransform transform;

@property (nonatomic, assign) float volumn;

@end

NS_ASSUME_NONNULL_END
