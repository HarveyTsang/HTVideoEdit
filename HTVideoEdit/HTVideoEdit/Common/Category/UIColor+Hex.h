//
//  UIColor+Hex.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Hex)

- (NSString *)ht_hexStringWithoutAlpha;// RRGGBB

+ (instancetype)ht_colorWithHex:(int32_t)hex;// 0xrrggbb

+ (instancetype)ht_colorWithHexString:(NSString *)hexString;

@end

NS_ASSUME_NONNULL_END
