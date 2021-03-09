//
//  HTVideoEditProgressBar.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTVideoEditProgressBar.h"
#import "HTTimeRangeDragTrackView.h"
#import "HTTimeRangeView.h"
#import "HTSectionClipViewDataSource.h"
#import "HTSectionClipScrollView.h"

@interface HTVideoEditProgressBar () <HTSectionClipScrollViewDataSource, HTSectionClipScrollViewDelegate, HTTimeRangeDragTrackViewDelegate>

@property (nonatomic, strong) NSMutableArray<HTSectionClipViewDataSource *> *sections;
@property (nonatomic, strong) HTSectionClipScrollView *scrollView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *indicateLine;
@property (nonatomic, strong) HTTimeRangeDragTrackView *maskView;
@property (nonatomic, strong) HTTimeRangeView *timeRangeView;
@property (nonatomic, assign) NSInteger currentSelectSection;
@property (nonatomic, assign) BOOL isMaskViewVisible;
@property (nonatomic, strong) UIView *currentMarkView;

@end

@implementation HTVideoEditProgressBar

- (instancetype)initWithAssets:(NSArray<AVAsset *> *)assets {
    if (self = [super init]) {
        self.sections = @[].mutableCopy;
        for (int i = 0; i < assets.count; i++) {
            AVAsset *asset = assets[i];
            HTSectionClipViewDataSource *section = [[HTSectionClipViewDataSource alloc] initWithAsset:asset];
            [self.sections addObject:section];
        }
        
        [self setupSubviews];
        
        self.backgroundColor = [UIColor ht_primaryColor];
        self.scrollView.backgroundColor = [UIColor ht_primaryColor];
    }
    return self;
}

- (void)setupSubviews {
    _scrollView = [[HTSectionClipScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.itemSize = [HTSectionClipViewDataSource itemSize];
    _scrollView.dataSource = self;
    _scrollView.delegate = self;
    [_scrollView.headInsertButton addTarget:self action:@selector(headInsertButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_scrollView.tailInsertButton addTarget:self action:@selector(tailInsertButtonClick) forControlEvents:UIControlEventTouchUpInside];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [_scrollView addGestureRecognizer:tap];
    [self addSubview:_scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self);
        make.centerY.equalTo(self);
        make.height.mas_equalTo(44.0);
    }];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage imageNamed:@"edit_play_button"] forState:UIControlStateNormal];
    [_playButton setImage:[UIImage imageNamed:@"edit_pause_button"] forState:UIControlStateSelected];
    [self addSubview:_playButton];
    [_playButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.offset(0);
        make.leading.offset(7);
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    
    _timeLabel = [UILabel new];
    _timeLabel.text = @"00:00";
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont systemFontOfSize:14];
    _timeLabel.textColor = [UIColor whiteColor];
    [self addSubview:_timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
        make.centerX.equalTo(self.playButton);
        make.size.mas_equalTo(CGSizeMake(56, 17));
    }];
    
    _indicateLine = [UIView new];
    _indicateLine.backgroundColor = [UIColor whiteColor];
    _indicateLine.layer.cornerRadius = 1.0;
    _indicateLine.layer.masksToBounds = YES;
    [self addSubview:_indicateLine];
    [_indicateLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@2);
        make.centerX.top.bottom.equalTo(self);
    }];
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.maskView.frame = self.bounds;
    
    CGFloat half = self.bounds.size.width/2.0;
    self.scrollView.contentInset = UIEdgeInsetsMake(0, half, 0, half);
}


- (HTTimeRangeView *)timeRangeView {
    if (!_timeRangeView) {
        _timeRangeView = [[HTTimeRangeView alloc] initWithFrame:CGRectMake(0, 0, 24.0, 44.0)];
        _timeRangeView.color = [UIColor ht_colorWithHexString:@"8DDCA4"];
        [self.scrollView addSubview:_timeRangeView];
    }
    return _timeRangeView;
}

- (CGRect)calculateFrameForTimeRange:(CMTimeRange)timeRange {
    CGFloat contentWidth = self.scrollView.contentSize.width;
    float duration = [self duration];//CMTimeGetSeconds(self.videoAsset.duration);
    CGFloat x = contentWidth*CMTimeGetSeconds(timeRange.start)/duration;
    CGFloat width = contentWidth*CMTimeGetSeconds(timeRange.duration)/duration;
    return CGRectMake(x, 2, width, 40);
}
- (CGRect)calculateTimeRangeViewFrameWithMarkView:(UIView *)markView {
    CGRect rect = [self.scrollView convertRect:markView.frame toView:self];
    return CGRectInset(rect, -12.0, -2.0);
}

- (CGRect)frameOfSectionViewAtSection:(NSUInteger)index {
    CGFloat x = 0.0;
    CGFloat width = self.sections[index].visualRange.length;
    for (NSUInteger i = 0; i < index; i++) {
        HTSectionClipViewDataSource *section = self.sections[i];
        x += section.visualRange.length;
    }
    return CGRectMake(x, 2.0, width, 40.0);
}

- (void)updateTimeLabel {
    int seconds = self.duration*_progress;
    int min = seconds/60;
    int sec = seconds%60;
    _timeLabel.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

#pragma mark - Getter
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [HTTimeRangeDragTrackView new];
        _maskView.delegate = self;
        _maskView.hidden = YES;
        [self addSubview:_maskView];
        [self bringSubviewToFront:self.indicateLine];
    }
    return _maskView;
}
- (BOOL)dragingTimeRangeView {
    HTTimeRangeView *timeRangeView = self.scrollView.timeRangeViewOfCurrentSelectSection;
    if (!timeRangeView) timeRangeView = _timeRangeView;
    return (timeRangeView != nil && !timeRangeView.hidden && timeRangeView.currentTouchPosition != KKTimeRangeViewTouchPositionNone);
}

- (CGFloat)contentLength {
    return self.scrollView.contentSize.width;
}

- (float)duration {
    float duration = 0;
    for (HTSectionClipViewDataSource *section in self.sections) {
        duration += CMTimeGetSeconds(section.trimTimeRange.duration);
    }
    return duration;
}

#pragma mark - Setter
- (void)setProgress:(double)progress {
    if (_progress == progress) return;
    if (self.scrollView.timeRangeViewOfCurrentSelectSection != nil && self.scrollView.timeRangeViewOfCurrentSelectSection.currentTouchPosition == KKTimeRangeViewTouchPositionNone) {
        CGRect frame = [self frameOfSectionViewAtSection:self.currentSelectSection];
        CGFloat start = frame.origin.x / self.contentLength;
        CGFloat end = (frame.origin.x + frame.size.width) / self.contentLength;
        if (progress < start || progress > end) {
            [self unselectSection];
        }
    }
    if (!_scrollView.dragging) {
        _progress = progress;
        CGFloat offsetX = _scrollView.contentSize.width*progress - _scrollView.contentInset.left;
        _scrollView.contentOffset = CGPointMake(offsetX, 0);
    }
}

- (void)setIsMaskViewVisible:(BOOL)isMaskViewVisible {
    if (_isMaskViewVisible != isMaskViewVisible) {
        _isMaskViewVisible = isMaskViewVisible;
        self.maskView.backgroundColor = isMaskViewVisible ? [UIColor.ht_primaryColor colorWithAlphaComponent:0.5] : [UIColor clearColor];
    }
}

- (void)scrollToLocation:(CGFloat)location {
    if (location < 0 || location > self.scrollView.contentSize.width) return;
    
    CGPoint offset = CGPointMake(location-self.scrollView.contentInset.left, 0);
    self.scrollView.contentOffset = offset;
}

#pragma mark - Action
- (void)headInsertButtonClick {
    if ([self.delegate respondsToSelector:@selector(progressBar:didClickInsertButtonWithType:)]) {
        [self.delegate progressBar:self didClickInsertButtonWithType:HTVideoEditProgressBarInsertSectionTypeHead];
    }
}
- (void)tailInsertButtonClick {
    if ([self.delegate respondsToSelector:@selector(progressBar:didClickInsertButtonWithType:)]) {
        [self.delegate progressBar:self didClickInsertButtonWithType:HTVideoEditProgressBarInsertSectionTypeTail];
    }
}

- (void)tapAction {
    [self unselectSection];
}

#pragma mark - Sticker
- (void)selectStickerWithTimeRange:(CMTimeRange)timeRange {
    if (CMTIMERANGE_IS_VALID(timeRange)) {
        if (_currentSelectSection >= 0) [self unselectSection];
        self.maskView.hidden = NO;
        self.timeRangeView.hidden = NO;
        CGRect frame = [self calculateFrameForTimeRange:timeRange];
        self.timeRangeView.frame = CGRectInset(frame, -12, -2);
    } else {
        if (_currentSelectSection >= 0) return;
        self.maskView.hidden = YES;
        self.timeRangeView.hidden = YES;
    }
}

- (void)changeStickerTimeRange:(CMTimeRange)timeRange {
    self.timeRangeView.frame = CGRectInset([self calculateFrameForTimeRange:timeRange], -12, -2);
}

- (void)changeStickerStartTime:(CMTime)startTime needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    CGFloat contentWidth = self.scrollView.contentSize.width;
    float duration = [self duration];
    CGFloat oldXStart = CGRectGetMinX(self.timeRangeView.frame);
    CGFloat xStart = contentWidth*CMTimeGetSeconds(startTime)/duration - 12;
    CGFloat xEnd = CGRectGetMaxX(self.timeRangeView.frame);
    CGRect frame = self.timeRangeView.frame;
    frame.origin.x = xStart;
    frame.size.width = xEnd-xStart;
    self.timeRangeView.frame = frame;
    if (needUpdateContentOffset) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x += xStart - oldXStart;
        self.scrollView.contentOffset = contentOffset;
    }
}

- (void)changeStickerEndTime:(CMTime)endTime needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    CGFloat contentWidth = self.scrollView.contentSize.width;
    float duration = [self duration];
    CGFloat oldXEnd = CGRectGetMaxX(self.timeRangeView.frame);
    CGFloat xEnd = contentWidth*CMTimeGetSeconds(endTime)/duration + 12;
    CGFloat xStart = CGRectGetMinX(self.timeRangeView.frame);
    CGRect frame = self.timeRangeView.frame;
    frame.size.width = xEnd-xStart;
    self.timeRangeView.frame = frame;
    if (needUpdateContentOffset) {
        CGPoint contentOffset = self.scrollView.contentOffset;
        contentOffset.x += xEnd - oldXEnd;
        self.scrollView.contentOffset = contentOffset;
    }
}

#pragma mark - Video Asset Section
- (void)insertAsset:(AVAsset *)asset atIndex:(NSUInteger)index {
    HTSectionClipViewDataSource *section = [[HTSectionClipViewDataSource alloc] initWithAsset:asset];
    [self.sections insertObject:section atIndex:index];
    [self.scrollView reloadData];
    
    if (_currentSelectSection != -1 && index <= _currentSelectSection) {
        _currentSelectSection++;
    }
}

- (void)removeAssetAtIndex:(NSUInteger)index {
    if (index < self.sections.count) {
        if (_currentSelectSection == index) {
            [self unselectSection];
        }
        [self.sections removeObjectAtIndex:index];
        [self.scrollView reloadData];
    }
}

- (void)selectSection:(NSUInteger)section {
    if (section > self.sections.count-1) return;
    
    self.maskView.hidden = NO;
    self.isMaskViewVisible = NO;
    _currentSelectSection = section;
    [self.scrollView selectSection:section];
}

- (void)unselectSection {
    self.maskView.hidden = YES;
    if (_currentSelectSection >= 0) {
        _currentSelectSection = -1;
        [self.scrollView unselect];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressBarDidUnselectSection:)]) {
        [self.delegate progressBarDidUnselectSection:self];
    }
}

- (void)changeStartTime:(CMTime)startTime ofAssetAtSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    if (self.currentSelectSection >= 0
        && self.currentSelectSection == section
        && self.scrollView.timeRangeViewOfCurrentSelectSection != nil
        && self.scrollView.timeRangeViewOfCurrentSelectSection.currentTouchPosition != KKTimeRangeViewTouchPositionNone) {
        self.scrollView.editing = YES;
        HTSectionClipViewDataSource *dataSource = self.sections[section];
        CMTime end = CMTimeRangeGetEnd(dataSource.trimTimeRange);
        dataSource.trimTimeRange = CMTimeRangeFromTimeToTime(startTime, end);
        [self.scrollView editVisualRangeStart:dataSource.visualRange.start atSection:section needUpdateContentOffset:needUpdateContentOffset];
    } else {
        HTSectionClipViewDataSource *dataSource = self.sections[section];
        CMTime end = CMTimeRangeGetEnd(dataSource.trimTimeRange);
        dataSource.trimTimeRange = CMTimeRangeFromTimeToTime(startTime, end);
        [self.scrollView changeVisualRange:dataSource.visualRange atSection:section needChangeContentOffset:needUpdateContentOffset];
    }
}

- (void)changeEndTime:(CMTime)endTime ofAssetAtSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    if (self.currentSelectSection >= 0
        && self.currentSelectSection == section
        && self.scrollView.timeRangeViewOfCurrentSelectSection != nil
        && self.scrollView.timeRangeViewOfCurrentSelectSection.currentTouchPosition != KKTimeRangeViewTouchPositionNone) {
        self.scrollView.editing = YES;
        HTSectionClipViewDataSource *dataSource =self.sections[section];
        CMTime start = dataSource.trimTimeRange.start;
        CMTime duration = CMTimeSubtract(endTime, start);
        dataSource.trimTimeRange = CMTimeRangeMake(start, duration);
        [self.scrollView editVisualRangeLength:dataSource.visualRange.length atSection:section needUpdateContentOffset:needUpdateContentOffset];
    } else {
        HTSectionClipViewDataSource *dataSource =self.sections[section];
        CMTime start = dataSource.trimTimeRange.start;
        CMTime duration = CMTimeSubtract(endTime, start);
        dataSource.trimTimeRange = CMTimeRangeMake(start, duration);
        [self.scrollView changeVisualRange:dataSource.visualRange atSection:section needChangeContentOffset:needUpdateContentOffset];
    }
}

#pragma mark - KKSectionClipScrollViewDataSource
- (NSUInteger)numberOfSection {
    return self.sections.count;
}
- (CGFloat)totalLengthOfSection:(NSUInteger)section {
    return self.sections[section].totalLength;
}
- (HTSectionVisualRange)visualRangeOfSection:(NSUInteger)section {
    return self.sections[section].visualRange;
}

- (UIView *)cellAtIndexPath:(NSIndexPath *)indexPath {
    UIImageView * imageView = (UIImageView *)[self.scrollView dequeueReusableCell];
    if (!imageView) {
        imageView = [UIImageView new];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
    }
    [self.sections[indexPath.section] queryImageAtIndex:indexPath.item forImageView:imageView];
    return imageView;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentSize.width <= 0.0) return;
    double progress = (scrollView.contentOffset.x+scrollView.contentInset.left)/scrollView.contentSize.width;
    progress = MIN(MAX(progress, 0.0), 1.0);
    if (progress == _progress) return;
    
    _progress = progress;
    [self updateTimeLabel];
    if (scrollView.isDragging && self.delegate && [self.delegate respondsToSelector:@selector(progressBar:dragToProgress:)]) {
        [self.delegate progressBar:self dragToProgress:progress];
    }
}
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:didEndDragToProgress:)]) {
            [self.delegate progressBar:self didEndDragToProgress:self.progress];
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:didEndDragToProgress:)]) {
        [self.delegate progressBar:self didEndDragToProgress:self.progress];
    }
}
#pragma mark - KKSectionClipScrollViewDelegate
- (void)sectionClipScrollView:(id)scrollView didClickSection:(NSUInteger)section {
    BOOL shouldSelect = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:shouldSelectSection:)]) {
        shouldSelect = [self.delegate progressBar:self shouldSelectSection:section];
    }
    if (shouldSelect) {
        [self selectSection:section];
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:didSelectSection:)]) {
            [self.delegate progressBar:self didSelectSection:section];
        }
    }
}

#pragma mark - HTTimeRangeDragTrackViewDelegate
- (BOOL)dragTrackView:(HTTimeRangeDragTrackView *)view shouldTouchBeginAtPoint:(CGPoint)point {
    HTTimeRangeView *timeRangeView = nil;
    if (self.currentSelectSection >= 0) {
        timeRangeView = self.scrollView.timeRangeViewOfCurrentSelectSection;
    } else if (!self.timeRangeView.hidden) {
        timeRangeView = self.timeRangeView;
    }
    if (!timeRangeView) return NO;
    CGPoint locationInTimeRangeView = [view convertPoint:point toView:timeRangeView];
    [timeRangeView touchWithLocation:locationInTimeRangeView];
    if (timeRangeView.currentTouchPosition != KKTimeRangeViewTouchPositionNone) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:beginDragTimeRangePosition:)]) {
            [self.delegate progressBar:self beginDragTimeRangePosition:self.scrollView.timeRangeViewOfCurrentSelectSection.currentTouchPosition];
        }
    }
    return timeRangeView.currentTouchPosition != KKTimeRangeViewTouchPositionNone;
}
- (void)dragTrackView:(HTTimeRangeDragTrackView *)view touchMove:(CGPoint)point {
    if (!self.delegate || ![self.delegate respondsToSelector:@selector(progressBar:dragTimeRangeDuration:position:isReachEdge:)]) return;
    
    CGRect rect = CGRectZero;
    HTTimeRangeView *timeRangeView = nil;
    if (_currentSelectSection >= 0) {
        rect = [self.scrollView frameOfSection:_currentSelectSection];
        timeRangeView = self.scrollView.timeRangeViewOfCurrentSelectSection;
    } else {
        rect = CGRectInset(self.timeRangeView.frame, 12, 2);
        timeRangeView = self.timeRangeView;
    }
    
    rect = [self.scrollView convertRect:rect toView:view];
    CGFloat start = 0.0;
    CGFloat end = 0.0;
    
    CGFloat increment = 10.0;
    CGFloat edgeWidth = 40.0;
    BOOL isReachEdge = YES;
    if (timeRangeView.currentTouchPosition == KKTimeRangeViewTouchPositionRight) {
        start = rect.origin.x;
        if (point.x < edgeWidth) {
            end = rect.origin.x + rect.size.width - increment;
        } else if (point.x > view.bounds.size.width-edgeWidth){
            end = rect.origin.x + rect.size.width + increment;
        } else {
            end = point.x-6.0;// 假设手指在timeRangeView的滑块的中间位置，故去掉滑块宽度的一半
            isReachEdge = NO;
        }
    } else {
        end = rect.origin.x + rect.size.width;
        if (point.x < edgeWidth) {
            start = rect.origin.x - increment;
        } else if (point.x > view.bounds.size.width-edgeWidth){
            start = rect.origin.x + increment;
        } else {
            start = point.x+6.0;// 假设手指在timeRangeView的滑块的中间位置，故去掉滑块宽度的一半
            isReachEdge = NO;
        }
    }
    CMTime duration = CMTimeMakeWithSeconds((end-start)/kPixelsSecond, 300);
    [self.delegate progressBar:self dragTimeRangeDuration:duration position:timeRangeView.currentTouchPosition isReachEdge:isReachEdge];
}

- (void)touchEndDragTrackView:(HTTimeRangeDragTrackView *)view {
    HTTimeRangeView *timeRangeView = nil;
    if (_currentSelectSection >= 0) {
        timeRangeView = self.scrollView.timeRangeViewOfCurrentSelectSection;
    } else {
        timeRangeView = self.timeRangeView;
    }
    KKTimeRangeViewTouchPosition position = timeRangeView.currentTouchPosition;
    timeRangeView.currentTouchPosition = KKTimeRangeViewTouchPositionNone;
    if (self.delegate && [self.delegate respondsToSelector:@selector(progressBar:endDragTimeRangePosition:)]) {
        [self.delegate progressBar:self endDragTimeRangePosition:position];
    }
    if (_currentSelectSection >= 0) [self.scrollView endEditVisualRange];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (CGRectContainsPoint(self.bounds, point)) {
        if (!_maskView.hidden) {
            if (CGRectContainsPoint(self.playButton.frame, point)) {
                return self.playButton;
            }
            HTTimeRangeView *timeRangeView = nil;
            if (self.currentSelectSection >= 0) {
                timeRangeView = self.scrollView.timeRangeViewOfCurrentSelectSection;
            } else if (!self.timeRangeView.hidden) {
                timeRangeView = self.timeRangeView;
            }
            if (timeRangeView) {
                CGPoint locationInTimeRangeView = [self convertPoint:point toView:timeRangeView];
                KKTimeRangeViewTouchPosition touchPosition = [timeRangeView touchPositionWithPoint:locationInTimeRangeView];
                if (touchPosition != KKTimeRangeViewTouchPositionNone) {
                    return _maskView;
                } else {
                    return _scrollView;
                }
            }
        }
    }
    
    return [super hitTest:point withEvent:event];
}

@end
