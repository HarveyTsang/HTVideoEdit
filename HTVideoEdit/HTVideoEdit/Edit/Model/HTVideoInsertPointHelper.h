//
//  HTVideoInsertPointHelper.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/1.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTInsertTime : NSObject

@property (nonatomic, assign) CMTime time;
@property (nonatomic, assign) float progress;

@end

@interface HTVideoInsertPointHelper : NSObject

- (instancetype)initWithInsertTimes:(NSArray<NSValue *> *)insertTimes duration:(CMTime)duration;
- (HTInsertTime *_Nullable)insertTimeObjectMatchProgress:(float)progress;
- (NSInteger)indexOfInsertTimeObjectMatchProgress:(float)progress;

@end

NS_ASSUME_NONNULL_END
