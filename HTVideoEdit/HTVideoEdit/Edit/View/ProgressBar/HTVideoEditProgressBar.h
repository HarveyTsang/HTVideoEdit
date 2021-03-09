//
//  HTVideoEditProgressBar.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HTTimeRangeView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, KKVideoEditProgressBarColorBlockType) {
    KKVideoEditProgressBarColorBlockTypeSticker,
    KKVideoEditProgressBarColorBlockTypeBackgroundAsset,
    KKVideoEditProgressBarColorBlockTypeAudio,
};

typedef NS_ENUM(NSUInteger, HTVideoEditProgressBarInsertSectionType) {
    HTVideoEditProgressBarInsertSectionTypeHead,
    HTVideoEditProgressBarInsertSectionTypeTail,
};

@class HTVideoEditProgressBar;
@protocol HTVideoEditProgressBarDelegate <NSObject>

- (void)progressBar:(HTVideoEditProgressBar *)progressBar dragToProgress:(double)progress;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar didEndDragToProgress:(double)progress;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar beginDragTimeRangePosition:(KKTimeRangeViewTouchPosition)position;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar dragTimeRangeDuration:(CMTime)duration position:(KKTimeRangeViewTouchPosition)position isReachEdge:(BOOL)isReachEdge;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar endDragTimeRangePosition:(KKTimeRangeViewTouchPosition)position;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar didClickInsertButtonWithType:(HTVideoEditProgressBarInsertSectionType)type;

- (BOOL)progressBar:(HTVideoEditProgressBar *)progressBar shouldSelectSection:(NSUInteger)section;

- (void)progressBar:(HTVideoEditProgressBar *)progressBar didSelectSection:(NSUInteger)section;

- (void)progressBarDidUnselectSection:(HTVideoEditProgressBar *)progressBar;

@end

@interface HTVideoEditProgressBar : UIView

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, weak, nullable) id<HTVideoEditProgressBarDelegate> delegate;

@property (nonatomic, assign) double progress;

@property (nonatomic, readonly) BOOL dragingTimeRangeView;

- (instancetype)initWithAssets:(NSArray<AVAsset *> *)assets;

- (void)insertAsset:(AVAsset *)asset atIndex:(NSUInteger)index;

- (void)removeAssetAtIndex:(NSUInteger)index;

- (void)selectSection:(NSUInteger)section;

- (void)changeStartTime:(CMTime)startTime ofAssetAtSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)changeEndTime:(CMTime)endTime ofAssetAtSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)selectStickerWithTimeRange:(CMTimeRange)timeRange;

- (void)changeStickerStartTime:(CMTime)startTime needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)changeStickerEndTime:(CMTime)endTime needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)scrollToLocation:(CGFloat)location;

- (CGFloat)contentLength;

@end

NS_ASSUME_NONNULL_END
