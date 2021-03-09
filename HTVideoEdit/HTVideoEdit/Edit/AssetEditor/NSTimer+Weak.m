//
//  NSTimer+Weak.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "NSTimer+Weak.h"

@implementation NSTimer (Weak)

+ (NSTimer *)ht_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(void))inBlock repeats:(BOOL)inRepeats {
    void (^block)(void) = [inBlock copy];
    NSTimer *timer = [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(ht_executeTimerBlock:) userInfo:block repeats:inRepeats];
    return timer;
}

+ (NSTimer *)ht_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(void))inBlock repeats:(BOOL)inRepeats {
    void (^block)(void) = [inBlock copy];
    NSTimer *timer = [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(ht_executeTimerBlock:) userInfo:block repeats:inRepeats];
    return timer;
}

+ (void)ht_executeTimerBlock:(NSTimer *)inTimer {
    if ([inTimer userInfo]) {
        void (^block)(void) = (void (^)(void))[inTimer userInfo];
        if (block) {
            block();
        }
    }
}

@end
