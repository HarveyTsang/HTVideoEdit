//
//  HTAssetEditor.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "HTAssetSegment.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^HTAssetEditorExportProgress)(float progress);
typedef void(^HTAssetEditorExportCompletion)(BOOL success, NSError *_Nullable error);

@interface HTAssetEditor : NSObject

/// 剔除无视轨的asset，将第一个视轨的宽高作为合成视频的宽高
/// @param assets 视频assets
- (instancetype _Nullable)initWithAssets:(NSArray<AVAsset *> *)assets;

/// 指定合成视频宽高
/// @param renderSize  视频宽高
- (instancetype)initWithRenderSize:(CGSize)renderSize;

/// 插入视频素材
/// @param asset 视频素材，需要包含视频轨
/// @param index 插入位置
- (void)insertVideoAsset:(AVAsset *)asset atIndex:(NSUInteger)index;

- (void)removeVideoAssetAtIndex:(NSUInteger)index;

- (CMTime)insertTimeOfVideoAssetAtIndex:(NSUInteger)index;

- (void)updateAssetTimeRange:(CMTimeRange)timeRange ofVideoAssetAtIndex:(NSUInteger)index;

- (AVPlayerItem *)createPlayItem;

- (void)exportToURL:(NSURL *)url
     withPresetName:(NSString *)presetName
     animationLayer:(CALayer * _Nullable)caLayer
           progress:(HTAssetEditorExportProgress _Nullable)progress
           complete:(HTAssetEditorExportCompletion _Nullable)completion;

- (void)cancelExport;

@property (nonatomic, strong, readonly) AVMutableComposition *composition;

@property (nonatomic, strong, readonly) NSArray<HTAssetSegment *> *assetSegments;

@end

NS_ASSUME_NONNULL_END
