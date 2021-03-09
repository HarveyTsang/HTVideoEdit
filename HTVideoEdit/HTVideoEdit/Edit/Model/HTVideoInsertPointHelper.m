//
//  HTVideoInsertPointHelper.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/1.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTVideoInsertPointHelper.h"

@implementation HTInsertTime

@end

@interface HTVideoInsertPointHelper ()

@property (nonatomic, strong) NSArray *insertTimes;
@property (nonatomic, assign) float progressToleration;

@end

@implementation HTVideoInsertPointHelper

- (instancetype)initWithInsertTimes:(NSArray<NSValue *> *)insertTimes duration:(CMTime)duration {
    if (self = [super init]) {
        NSMutableArray *array = @[].mutableCopy;
        for (NSValue *value in insertTimes) {
            HTInsertTime *insertTime = [HTInsertTime new];
            insertTime.time = value.CMTimeValue;
            insertTime.progress = CMTimeGetSeconds(insertTime.time)/CMTimeGetSeconds(duration);
            [array addObject:insertTime];
        }
        _insertTimes = array;
        _progressToleration = 0.2/CMTimeGetSeconds(duration);
    }
    return self;
}

- (HTInsertTime *)insertTimeObjectMatchProgress:(float)progress {
    for (HTInsertTime *obj in _insertTimes) {
        if (fabs(obj.progress-progress) < _progressToleration) return obj;
    }
    return nil;
}

- (NSInteger)indexOfInsertTimeObjectMatchProgress:(float)progress {
    HTInsertTime *obj = [self insertTimeObjectMatchProgress:progress];
    if (obj) return [_insertTimes indexOfObject:obj];
    return -1;
}

@end
