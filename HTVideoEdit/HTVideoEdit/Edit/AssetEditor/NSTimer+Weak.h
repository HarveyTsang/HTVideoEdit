//
//  NSTimer+Weak.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (Weak)

+ (NSTimer *)ht_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(void))inBlock repeats:(BOOL)inRepeats;

+ (NSTimer *)ht_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(void))inBlock repeats:(BOOL)inRepeats;

@end

NS_ASSUME_NONNULL_END
