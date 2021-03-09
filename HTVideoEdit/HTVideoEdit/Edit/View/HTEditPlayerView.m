//
//  HTEditPlayerView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTEditPlayerView.h"
#import "HTStickerHighlightView.h"
#import "HTTextStickerView.h"
#import "HTImageStickerView.h"
#import "HTTextInputViewController.h"

@interface HTEditPlayerView ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) UIView *stickerContainerView;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) NSMutableArray<HTStickerView *> *stickers;
@property (nonatomic, strong) HTStickerView *currentSelectedSticker;

@end

@implementation HTEditPlayerView

- (instancetype)initWithPlayer:(AVPlayer *)player {
    if (self = [super init]) {
        UIColor *backgroundColor = UIColor.blackColor;
        self.backgroundColor = backgroundColor;
        _player = player;
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
        _playerLayer.backgroundColor = backgroundColor.CGColor;
        [self.layer addSublayer:_playerLayer];
        
        _stickerContainerView = [UIView new];
        _stickerContainerView.layer.masksToBounds = YES;
        [self addSubview:_stickerContainerView];
        
        [self addTimeObserverToPlayer];
        
        _stickers = @[].mutableCopy;
        
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapRecognizer];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.maximumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGSize renderSize = self.player.currentItem.videoComposition.renderSize;
    if (renderSize.height == 0) return;
    CGFloat renderRatio = renderSize.width / renderSize.height;
    CGRect renderRect = [self fitRectInBoxSize:self.bounds.size ratio:renderRatio];
    _playerLayer.frame = renderRect;
    _stickerContainerView.frame = renderRect;
}

- (void)dealloc {
    [self removeTimeObserverFromPlayer];
}

#pragma mark - Actions
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    if (self.currentSelectedSticker) {
        CGPoint point = [recognizer locationInView:self.currentSelectedSticker];
        [self.currentSelectedSticker touchWithPoint:point];
        NSString *clickType = self.currentSelectedSticker.highlightViewActionType;
        if (clickType) {
            [self clickHighlightViewWithType:clickType];
            return;
        }
    }

    HTStickerView *hitSticker = nil;
    for (HTStickerView *sticker in [self.stickers reverseObjectEnumerator]) {
        if (!sticker.isHidden) {
            CGPoint locationInStickerView = [recognizer locationInView:sticker];
            if (CGRectContainsPoint(sticker.bounds, locationInStickerView)) {
                hitSticker = sticker;
                break;
            }
        }
    }
    if (hitSticker != self.currentSelectedSticker) {
        [self _selectSticker:hitSticker];
    }
}
- (void)handlePan:(UIPanGestureRecognizer *)recognizer {
    static BOOL isMove = YES;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self.currentSelectedSticker];
        [self.currentSelectedSticker touchWithPoint:point];
        NSString *clickType = self.currentSelectedSticker.highlightViewActionType;
        if (clickType && [clickType isEqualToString:HTStickerHightlightViewActionTypeScaleAndRotate]) {
            isMove = NO;
            return;
        }
        isMove = YES;
        CGPoint locationInHightlightView = [recognizer locationInView:self.currentSelectedSticker];
        if (!CGRectContainsPoint(self.currentSelectedSticker.bounds, locationInHightlightView) || !self.currentSelectedSticker) {
            recognizer.enabled = NO;
            recognizer.enabled = YES;
            return;
        }
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        if (isMove) {
            CGPoint translatePoint = [recognizer translationInView:recognizer.view.superview];
            CGPoint center = self.currentSelectedSticker.center;
            center.x += translatePoint.x;
            center.y += translatePoint.y;
            _currentSelectedSticker.center = center;
            [recognizer setTranslation:CGPointZero inView:recognizer.view.superview];
        } else {
            CGPoint center = self.currentSelectedSticker.center;
            CGFloat width = self.currentSelectedSticker.bounds.size.width;
            CGFloat height = self.currentSelectedSticker.bounds.size.height;
            CGPoint startPoint = [self.currentSelectedSticker locationOfScaleAndRotateActionView];
            CGPoint currentLocation = [recognizer locationInView:self.currentSelectedSticker.superview];
            CGPoint endPoint = CGPointMake(currentLocation.x-center.x, currentLocation.y-center.y);
            CGFloat startAngle = atan2(startPoint.y, startPoint.x) * 180/M_PI;
            CGFloat endAngle = atan2(endPoint.y, endPoint.x) * 180/M_PI;
            CGFloat rotateAngle = endAngle-startAngle;
            CGFloat startLength = sqrt(startPoint.x*startPoint.x + startPoint.y*startPoint.y);
            CGFloat endLength = sqrt(endPoint.x*endPoint.x + endPoint.y*endPoint.y);
            CGFloat scale = endLength/startLength;

            CGFloat newWidth = width*scale;
            CGFloat newHeight = height*scale;
            if (newWidth >= 20.0 && newHeight >= 20.0) {
                CGRect bounds = CGRectMake(0, 0, newWidth, newHeight);
                self.currentSelectedSticker.bounds = bounds;
            }
            CGAffineTransform newTransform = CGAffineTransformRotate(CGAffineTransformIdentity, rotateAngle*M_PI/180);
            self.currentSelectedSticker.transform = newTransform;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        if (!isMove && [self.currentSelectedSticker isKindOfClass:[HTTextStickerView class]]) {
            [(HTTextStickerView *)self.currentSelectedSticker update];
        }
    }
}

- (void)clickHighlightViewWithType:(NSString *)type {
    if ([type isEqualToString:HTStickerHightlightViewActionTypeRemove]) {
        HTStickerView *sticker = _currentSelectedSticker;
        [self _selectSticker:nil];
        [self deleteSticker:sticker];
    } else if ([type isEqualToString:HTStickerHightlightViewActionTypeEdit]) {
        HTTextInputViewController *textInput = [[HTTextInputViewController alloc] init];
        [textInput setText:((HTTextStickerView *)self.currentSelectedSticker).text];
        __weak typeof(self) ws = self;
        textInput.textChange = ^(NSString *text) {
            ((HTTextStickerView *)ws.currentSelectedSticker).text = text;
        };
        [textInput show];
    }
}

- (void)selectSticker:(HTStickerView *)sticker {
    if (_currentSelectedSticker == sticker) return;
    if (sticker && ![_stickers containsObject:sticker]) return;

    _currentSelectedSticker.selected = NO;
    _currentSelectedSticker = sticker;
    _currentSelectedSticker.selected = YES;
}

- (void)_selectSticker:(HTStickerView *)sticker {
    [self selectSticker:sticker];
    if (self.delegate && [self.delegate respondsToSelector:@selector(editPlayerView:didSelectSticker:)]) {
        [self.delegate editPlayerView:self didSelectSticker:_currentSelectedSticker];
    }
}

- (CGRect)fitRectInBoxSize:(CGSize)boxSize ratio:(CGFloat)ratio {
    CGFloat boxRatio = boxSize.width / boxSize.height;
    CGRect frame = CGRectZero;
    if (ratio > boxRatio) {
        frame.size.width = boxSize.width;
        frame.size.height = frame.size.width / ratio;
    }
    else {
        frame.size.height = boxSize.height;
        frame.size.width = frame.size.height * ratio;
    }
    frame.origin.x = (boxSize.width - frame.size.width) / 2.0;
    frame.origin.y = (boxSize.height - frame.size.height) / 2.0;
    return frame;
}

- (void)addTimeObserverToPlayer {
    if (_timeObserver) return;

    __weak typeof(self) weakSelf = self;
    _timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.1, NSEC_PER_SEC) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        [weakSelf setCurrentPlayTime:time];
    }];
}
- (void)removeTimeObserverFromPlayer  {
    if (_timeObserver) {
        [self.player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
}

- (void)setCurrentPlayTime:(CMTime)time {
    for (HTStickerView *sticker in self.stickers) {
        if (sticker != _currentSelectedSticker) { // 考虑到若此时有sticker被选中，则它应该一直在画面中展示，故跳过对它的隐藏
            sticker.hidden = !CMTimeRangeContainsTime(sticker.timeRange, time);
        }
    }
}

- (void)addSticker:(HTStickerView *)sticker {
    [_stickers addObject:sticker];
    UIView *containerView = self.stickerContainerView;
    CGRect frame = sticker.frame;
    CGSize containerSize = containerView.frame.size;
    frame.origin.x = (containerSize.width-frame.size.width)/2.0;
    frame.origin.y = (containerSize.height-frame.size.height)/2.0;
    sticker.frame = frame;
    [containerView addSubview:sticker];
}

- (void)deleteSticker:(HTStickerView *)sticker {
    [sticker removeFromSuperview];
    [_stickers removeObject:sticker];
    if (self.currentSelectedSticker == sticker) {
        self.currentSelectedSticker = nil;
    }
}

- (void)cancelSelectSticker {
    if (!_currentSelectedSticker) return;
    _currentSelectedSticker.selected = NO;
    _currentSelectedSticker = nil;
}

- (void)adjustStickersTimeRangeWithMinDuration:(CMTime)minDuration {
    CMTime totalDuration = self.player.currentItem.asset.duration;
    NSMutableIndexSet *deleteIndexSet = [NSMutableIndexSet indexSet];
    for (int i = 0; i < _stickers.count; i++) {
        CMTime endTimeOfSticker = CMTimeRangeGetEnd(_stickers[i].timeRange);
        if (CMTimeCompare(totalDuration, endTimeOfSticker) < 0) {
            CMTimeRange newTimeRange = CMTimeRangeFromTimeToTime(_stickers[i].timeRange.start, totalDuration);
            if (CMTIMERANGE_IS_INVALID(newTimeRange) || CMTimeCompare(newTimeRange.duration, minDuration) < 0) {
                [deleteIndexSet addIndex:i];
                [_stickers[i] removeFromSuperview];
            }
        }
    }
    if (deleteIndexSet.count > 0) {
        [_stickers removeObjectsAtIndexes:deleteIndexSet];
    }
}

- (CALayer *)createStickerContainerLayerForVideoExport {
    if (_stickers.count == 0) return nil;
    CGSize renderSize = self.player.currentItem.videoComposition.renderSize;
    CGFloat ratio = renderSize.width/_stickerContainerView.bounds.size.width;
    CGRect containerFrame = CGRectMake(0, 0, renderSize.width, renderSize.height);
    CALayer *containerLayer = [CALayer layer];
    containerLayer.frame = containerFrame;
    
    for (HTStickerView *sticker in self.stickers) {
        CALayer *layer = [sticker layerWithScale:ratio];
        CGRect layerFrame = layer.frame;
        layerFrame.origin.y = renderSize.height-layerFrame.size.height-layerFrame.origin.y;
        layer.frame = layerFrame;
        layer.affineTransform = [self adjustTransform:sticker.transform];
        CAKeyframeAnimation *animation = [self opacityAnimationWithTimeRange:sticker.timeRange totalDuration:CMTimeGetSeconds(self.player.currentItem.asset.duration)];
        [layer addAnimation:animation forKey:@"animateOpacity"];
        [containerLayer addSublayer:layer];
    }
    return containerLayer;
}

- (CGAffineTransform)adjustTransform:(CGAffineTransform)transform {
    CGFloat radian = atan2(transform.b, transform.a);
    return CGAffineTransformRotate(CGAffineTransformIdentity, -radian);
}

- (CAKeyframeAnimation *)opacityAnimationWithTimeRange:(CMTimeRange)timeRange totalDuration:(float)totalSeconds {
    NSNumber *appearPoint = @(CMTimeGetSeconds(timeRange.start)/totalSeconds);
    NSNumber *disappearPoint = @(CMTimeGetSeconds(CMTimeAdd(timeRange.start, timeRange.duration))/totalSeconds);
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"opacity"];
    animation.values = @[@0, @0, @1, @1, @0, @0];
    animation.keyTimes = @[@0, appearPoint, appearPoint, disappearPoint, disappearPoint, @1];
    animation.removedOnCompletion = NO;
    animation.beginTime = AVCoreAnimationBeginTimeAtZero;
    animation.duration = totalSeconds;
    
    return animation;
}

@end
