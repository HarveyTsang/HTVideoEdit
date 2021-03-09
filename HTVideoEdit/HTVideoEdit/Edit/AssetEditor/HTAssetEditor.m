//
//  HTAssetEditor.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTAssetEditor.h"
#import "AVAssetTrack+HTHelper.h"
#import "AVMutableCompositionTrack+HTHelper.h"
#import "NSTimer+Weak.h"

@interface HTAssetEditor ()

@property (nonatomic, assign) CGSize renderSize;// 最终合成视频的宽高
@property (nonatomic, strong) NSMutableArray<HTAssetSegment *> *assetSegments;
@property (nonatomic, strong) AVMutableCompositionTrack *passThroughVideoCompositionTrack;
@property (nonatomic, strong) AVMutableCompositionTrack *passThroughAudioCompositionTrack;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVMutableComposition *composition;
@property (nonatomic, strong) AVAssetExportSession *exportSession;
@property (nonatomic, strong) NSTimer *progressTimer;
@property (nonatomic, copy) HTAssetEditorExportProgress exportProgressBlock;
@property (nonatomic, copy) HTAssetEditorExportCompletion exportCompletionBlock;

@end

@implementation HTAssetEditor

- (instancetype)initWithAssets:(NSArray<AVAsset *> *)assets {
    NSMutableArray *videoAssets = @[].mutableCopy;
    for (AVAsset *asset in assets) {
        if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) continue;
        [videoAssets addObject:asset];
    }
    if (videoAssets.count == 0) return nil;
    AVAssetTrack *videoTrack = [videoAssets[0] tracksWithMediaType:AVMediaTypeVideo][0];
    HTAssetEditor *editor = [[HTAssetEditor alloc] initWithRenderSize:videoTrack.ht_renderSize];
    for (int i = 0; i < videoAssets.count; i++) {
        AVAsset *asset = videoAssets[i];
        [editor appendVideoAsset:asset];
    }
    return editor;
}

- (instancetype)initWithRenderSize:(CGSize)renderSize {
    if (self = [super init]) {
        _renderSize = renderSize;
        _composition = [AVMutableComposition composition];
        _composition.naturalSize = renderSize;
        _passThroughVideoCompositionTrack = [_composition addMutableTrackWithMediaType:AVMediaTypeVideo
                                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
        _passThroughAudioCompositionTrack = [_composition addMutableTrackWithMediaType:AVMediaTypeAudio
                                                                      preferredTrackID:kCMPersistentTrackID_Invalid];
        _assetSegments = @[].mutableCopy;
    }
    return self;
}
- (void)appendVideoAsset:(AVAsset *)asset {
    [self insertVideoAsset:asset atIndex:_assetSegments.count];
}
- (void)insertVideoAsset:(AVAsset *)asset atIndex:(NSUInteger)index {
    if (index > _assetSegments.count) return;
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) return;
    AVAssetTrack *videoTrack = [asset tracksWithMediaType:AVMediaTypeVideo][0];
    AVAssetTrack *audioTrack = nil;
    if ([asset tracksWithMediaType:AVMediaTypeAudio].count > 0) audioTrack = [asset tracksWithMediaType:AVMediaTypeAudio][0];
    CMTime duration = videoTrack.timeRange.duration;
    if (audioTrack) {
        duration = CMTimeMinimum(duration, audioTrack.timeRange.duration);
    }
    CMTime insertTime = [self insertTimeWithIndex:index];
    
    HTTrackSegment *videoTrackSegment = [self insertAssetTrack:videoTrack
                                                   ofTimeRange:CMTimeRangeMake(videoTrack.timeRange.start, duration)
                                            toCompositionTrack:_passThroughVideoCompositionTrack
                                                        atTime:insertTime];
    if (!videoTrackSegment) return;
    
    HTTrackSegment *audioTrackSegment = nil;
    if (audioTrack) {
        audioTrackSegment = [self insertAssetTrack:audioTrack
                                       ofTimeRange:CMTimeRangeMake(audioTrack.timeRange.start, duration)
                                toCompositionTrack:_passThroughAudioCompositionTrack
                                            atTime:insertTime];
    }
    if (!audioTrackSegment) {
        [_passThroughAudioCompositionTrack insertEmptyTimeRange:CMTimeRangeMake(insertTime, duration)];
    }
    HTAssetSegment *assetSegment = [[HTAssetSegment alloc] initWithAsset:asset
                                                          assetTimeRange:CMTimeRangeMake(videoTrack.timeRange.start, duration)
                                                             maxDuration:duration
                                                              videoTrack:videoTrackSegment
                                                              audioTrack:audioTrackSegment];
    [_assetSegments insertObject:assetSegment atIndex:index];
}

- (void)removeVideoAssetAtIndex:(NSUInteger)index {
    if (index >= _assetSegments.count) return;
    HTAssetSegment *segment = _assetSegments[index];
    CMTime insertTime = [self insertTimeOfVideoAssetAtIndex:index];
    CMTimeRange timeRange = CMTimeRangeMake(insertTime, segment.assetTimeRange.duration);
    [_passThroughVideoCompositionTrack removeTimeRange:timeRange];
    [_passThroughAudioCompositionTrack removeTimeRange:timeRange];
    [_assetSegments removeObjectAtIndex:index];
}

- (CMTime)insertTimeOfVideoAssetAtIndex:(NSUInteger)index {
    if (index >= _assetSegments.count) return kCMTimeInvalid;
    CMTime insertTime = kCMTimeZero;
    for (int i = 0; i < index; i++) {
        insertTime = CMTimeAdd(insertTime, _assetSegments[i].assetTimeRange.duration);
    }
    return insertTime;
}

- (void)updateAssetTimeRange:(CMTimeRange)timeRange ofVideoAssetAtIndex:(NSUInteger)index {
    if (index >= _assetSegments.count) return;
    CMTime insertTime = [self insertTimeOfVideoAssetAtIndex:index];
    [_assetSegments[index] updateAssetTimeRange:timeRange withInsertTime:insertTime];
}

- (AVPlayerItem *)createPlayItem {
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:self.composition.copy];
    playerItem.videoComposition = [self createVideoComposition];
    playerItem.audioMix = [self createAudioMix];
    return playerItem;
}

- (void)exportToURL:(NSURL *)url withPresetName:(NSString *)presetName animationLayer:(CALayer * _Nullable)caLayer progress:(HTAssetEditorExportProgress _Nullable)progress complete:(HTAssetEditorExportCompletion _Nullable)completion {
    if (_exportSession) return;
    _exportProgressBlock = progress;
    _exportCompletionBlock = completion;
    _exportSession = [[AVAssetExportSession alloc] initWithAsset:self.composition presetName:presetName];
    AVMutableVideoComposition *videoComposition = [self createVideoComposition];
    if (caLayer) {
        CALayer *parentLayer = [CALayer layer];
        parentLayer.frame = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
        CALayer *videoLayer = [CALayer layer];
        videoLayer.frame = CGRectMake(0, 0, self.renderSize.width, self.renderSize.height);
        [parentLayer addSublayer:videoLayer];
        [parentLayer addSublayer:caLayer];
        videoComposition.animationTool = [AVVideoCompositionCoreAnimationTool videoCompositionCoreAnimationToolWithPostProcessingAsVideoLayer:videoLayer inLayer:parentLayer];
    }
    _exportSession.videoComposition = videoComposition;
    _exportSession.audioMix = [self createAudioMix];
    _exportSession.outputURL = url;
    _exportSession.outputFileType = AVFileTypeMPEG4;

    __weak typeof(self) ws = self;
    if (progress) {
        _progressTimer = [NSTimer ht_scheduledTimerWithTimeInterval:0.5 block:^{
            ws.exportProgressBlock(ws.exportSession.progress);
        } repeats:YES];
    }
    [_exportSession exportAsynchronouslyWithCompletionHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            if (ws.exportSession.status == AVAssetExportSessionStatusCompleted) {
                if (ws.exportCompletionBlock) ws.exportCompletionBlock(YES, nil);
            } else {
                if (ws.exportCompletionBlock) ws.exportCompletionBlock(NO, ws.exportSession.error);
            }
            [ws cleanExportStatus];
        });
    }];
}

- (void)cancelExport {
    [self.exportSession cancelExport];
    [self cleanExportStatus];
}
- (void)cleanExportStatus {
    _exportSession = nil;
    _exportProgressBlock = nil;
    _exportCompletionBlock = nil;
    [_progressTimer invalidate];
    _progressTimer = nil;
}

- (AVMutableVideoComposition *)createVideoComposition {
    AVMutableVideoComposition *videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.instructions = [self createInstructions];
    videoComposition.frameDuration = CMTimeMake(1, 30);
    videoComposition.renderSize = _renderSize;
    return videoComposition;
}

- (NSMutableArray *)createInstructions {
    NSMutableArray *instructions = @[].mutableCopy;
    for (int i = 0; i < _assetSegments.count; i++) {
        HTAssetSegment *segment = _assetSegments[i];
        if (!segment.videoTrack) continue;
        AVMutableVideoCompositionInstruction *instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
        CMTime insertTime = [self insertTimeOfVideoAssetAtIndex:i];
        instruction.timeRange = CMTimeRangeMake(insertTime, segment.assetTimeRange.duration);
        AVMutableVideoCompositionLayerInstruction *layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:segment.videoTrack.compositionTrack];
        [layerInstruction setTransform:segment.videoTrack.transform
                                atTime:insertTime];
        instruction.layerInstructions = @[layerInstruction];
        [instructions addObject:instruction];
    }
    return instructions;
}

- (AVMutableAudioMix *)createAudioMix {
    AVMutableAudioMix *audioMix = [AVMutableAudioMix audioMix];
    NSMutableArray *inputParameters = @[].mutableCopy;
    for (int i = 0; i < self.assetSegments.count; i++) {
        HTAssetSegment *segment = self.assetSegments[i];
        if (!segment.audioTrack) continue;
        CMTime insertTime = [self insertTimeOfVideoAssetAtIndex:i];
        AVMutableAudioMixInputParameters *parameters = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:segment.audioTrack.compositionTrack];
        [parameters setVolume:0 atTime:kCMTimeZero];
        [parameters setVolume:segment.audioTrack.volumn atTime:insertTime];
        [parameters setVolume:0 atTime:CMTimeAdd(insertTime, segment.assetTimeRange.duration)];
        [inputParameters addObject:parameters];
    }
    audioMix.inputParameters = inputParameters;
    return audioMix;
}
- (HTTrackSegment *)insertAssetTrack:(AVAssetTrack *)assetTrack ofTimeRange:(CMTimeRange)timeRange toCompositionTrack:(AVMutableCompositionTrack *)compositionTrack atTime:(CMTime)insertTime {
    HTTrackSegment *trackSegment = [HTTrackSegment new];
    trackSegment.assetTrack = assetTrack;
    trackSegment.timeRange = timeRange;
    trackSegment.compositionTrack = compositionTrack;
    if ([assetTrack.mediaType isEqualToString:AVMediaTypeVideo]) {
        trackSegment.transform = [assetTrack ht_transformFitBox:_renderSize];
    }
    BOOL success = [compositionTrack insertTimeRange:timeRange
                                             ofTrack:assetTrack
                                              atTime:insertTime
                                               error:nil];
    if (!success) return nil;
    return trackSegment;
}

- (CMTime)insertTimeWithIndex:(NSUInteger)index {
    index = (int)MAX(MIN(index, self.assetSegments.count), 0);
    CMTime insertTime = kCMTimeZero;
    for (int i = 0; i < index; i++) {
        insertTime = CMTimeAdd(insertTime, self.assetSegments[i].assetTimeRange.duration);
    }
    return insertTime;
}

@end
