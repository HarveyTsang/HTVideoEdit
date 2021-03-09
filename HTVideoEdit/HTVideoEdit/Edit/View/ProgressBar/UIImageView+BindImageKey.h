//
//  UIImageView+BindImageKey.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (BindImageKey)

- (NSString *_Nullable)indexKey;
- (void)setIndexKey:(NSString *_Nullable)indexKey;

@end

NS_ASSUME_NONNULL_END
