//
//  AVMutableCompositionTrack+HTHelper.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AVMutableCompositionTrack (HTHelper)

- (BOOL)ht_isAvailableForTimeRange:(CMTimeRange)timeRange;

@end

NS_ASSUME_NONNULL_END
