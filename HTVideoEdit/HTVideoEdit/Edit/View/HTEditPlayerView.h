//
//  HTEditPlayerView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "HTStickerView.h"

NS_ASSUME_NONNULL_BEGIN

@class HTEditPlayerView;
@protocol HTEditPlayerViewDelegate <NSObject>

@optional
- (void)editPlayerView:(HTEditPlayerView *)playerView didSelectSticker:(HTStickerView *_Nullable)sticker;

@end

@interface HTEditPlayerView : UIView

@property (nonatomic, weak, nullable) id<HTEditPlayerViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray<HTStickerView *> *stickers;

@property (nonatomic, strong, readonly, nullable) HTStickerView *currentSelectedSticker;

- (instancetype)initWithPlayer:(AVPlayer *)player;

- (void)addSticker:(HTStickerView *)sticker;

- (void)deleteSticker:(HTStickerView *)sticker;

- (void)selectSticker:(HTStickerView *)sticker;

- (void)cancelSelectSticker;

- (void)adjustStickersTimeRangeWithMinDuration:(CMTime)minDuration;

- (CALayer *_Nullable)createStickerContainerLayerForVideoExport;

@end

NS_ASSUME_NONNULL_END
