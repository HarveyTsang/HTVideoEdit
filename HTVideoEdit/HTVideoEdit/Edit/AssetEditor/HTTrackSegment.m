//
//  HTTrackSegment.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTrackSegment.h"

@implementation HTTrackSegment

- (instancetype)init {
    if (self = [super init]) {
        _transform = CGAffineTransformIdentity;
        _volumn = 1.0;
    }
    return self;
}

@end
