//
//  AVMutableCompositionTrack+HTHelper.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "AVMutableCompositionTrack+HTHelper.h"
#import <objc/runtime.h>

@implementation AVMutableCompositionTrack (HTHelper)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self ht_swizzle:@selector(insertTimeRange:ofTrack:atTime:error:) with:@selector(ht_insertTimeRange:ofTrack:atTime:error:)];
        [self ht_swizzle:@selector(removeTimeRange:) with:@selector(ht_removeTimeRange:)];
    });
}

+ (void)ht_swizzle:(SEL)oriSEL with:(SEL)swizzlingSEL {
    Method oriMethod = class_getInstanceMethod(self, oriSEL);
    Method swiMethod = class_getInstanceMethod(self, swizzlingSEL);
    BOOL didAddMethod = class_addMethod(self,
                                        oriSEL,
                                        method_getImplementation(swiMethod),
                                        method_getTypeEncoding(swiMethod));
    if (didAddMethod) {
        class_replaceMethod(self,
                            swizzlingSEL,method_getImplementation(oriMethod),
                            method_getTypeEncoding(oriMethod));
    } else {
        method_exchangeImplementations(oriMethod, swiMethod);
    }
}

- (BOOL)ht_insertTimeRange:(CMTimeRange)timeRange ofTrack:(AVAssetTrack *)track atTime:(CMTime)startTime error:(NSError * _Nullable __autoreleasing *)outError {
    BOOL r = [self ht_insertTimeRange:timeRange ofTrack:track atTime:startTime error:outError];
    if (r) {
        CMTimeRange tr = CMTimeRangeMake(startTime, timeRange.duration);
        [[self ht_timeRanges] addObject:[NSValue valueWithCMTimeRange:tr]];
    }
    return r;
}

- (void)ht_removeTimeRange:(CMTimeRange)timeRange {
    [self ht_removeTimeRange:timeRange];
    NSMutableArray *timeRanges = [self ht_timeRanges];
    [timeRanges removeObject:[NSValue valueWithCMTimeRange:timeRange]];
}

- (NSMutableArray *)ht_timeRanges {
    NSMutableArray *timeRanges = objc_getAssociatedObject(self, @selector(ht_timeRanges));
    if (!timeRanges) {
        timeRanges = @[].mutableCopy;
        objc_setAssociatedObject(self, @selector(ht_timeRanges), timeRanges, OBJC_ASSOCIATION_RETAIN);
    }
    return timeRanges;
}

- (BOOL)ht_isAvailableForTimeRange:(CMTimeRange)timeRange {
    NSArray *timeRanges = [self ht_timeRanges];
    for (NSValue *value in timeRanges) {
        CMTimeRange tr = value.CMTimeRangeValue;
        if (CMTimeRangeContainsTime(tr, timeRange.start) ||
            CMTimeRangeContainsTime(tr, CMTimeRangeGetEnd(timeRange))) {
            return NO;
        }
    }
    return YES;
}

@end
