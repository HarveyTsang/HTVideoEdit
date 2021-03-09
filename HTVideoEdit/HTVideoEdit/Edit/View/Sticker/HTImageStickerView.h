//
//  HTImageStickerView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTStickerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTImageStickerView : HTStickerView

- (instancetype)initWithImageURL:(NSURL *)imageURL;

@property (nonatomic, strong) NSURL *URL;

@end

NS_ASSUME_NONNULL_END
