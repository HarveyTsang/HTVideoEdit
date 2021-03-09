//
//  UIColor+App.m
//  HTVideoEdit
//
//  Created by mac on 2021/3/9.
//

#import "UIColor+App.h"

@implementation UIColor (App)

+ (instancetype)ht_primaryColor {
    return [UIColor ht_colorWithHexString:@"00171F"];
}

+ (instancetype)ht_lineColor {
    return [UIColor ht_colorWithHexString:@"313653"];
}

+ (instancetype)ht_selectedColor {
    return [UIColor ht_colorWithHexString:@"CC5A71"];
}

@end
