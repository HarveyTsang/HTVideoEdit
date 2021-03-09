//
//  HTVideoEditToolView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTStickerView.h"

NS_ASSUME_NONNULL_BEGIN

@class HTVideoEditToolView;
@protocol HTVideoEditToolViewDelegate <NSObject>

@optional
- (void)videoEditToolViewDidClickInsertVideo:(HTVideoEditToolView *)toolView;
- (void)videoEditToolViewDidClickRemoveVideo:(HTVideoEditToolView *)toolView;
- (void)videoEditToolViewDidClickAddText:(HTVideoEditToolView *)toolView;
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectColor:(UIColor *)color;
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectFont:(NSString *)fontName;
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectImage:(NSURL *)url;
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didCancelSelectSticker:(HTStickerView *)sticker;

@end

@interface HTVideoEditToolView : UIView

@property (nonatomic, weak, nullable)id<HTVideoEditToolViewDelegate> delegate;

@property (nonatomic, assign) BOOL enableInsertVideo;

@property (nonatomic, assign) BOOL enableRemoveVideo;

@property (nonatomic, assign) BOOL enableAddSticker;

- (void)selectSticker:(HTStickerView *_Nullable)sticker;

@end

NS_ASSUME_NONNULL_END
