//
//  UIColor+Hex.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/8.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

- (NSString *)ht_hexStringWithoutAlpha {
    CGFloat r,g,b = 0;
    [self getRed:&r green:&g blue:&b alpha:nil];
    
    int32_t red = r * 255;
    int32_t green = g * 255;
    int32_t blue = b * 255;
    return [NSString stringWithFormat:@"%02X%02X%02X", red, green, blue];
}

+ (instancetype)ht_colorWithHex:(int32_t)hex {
    CGFloat b = (hex&0xFF)/255.0;
    CGFloat g = ((hex>>8)&0xFF)/255.0;
    CGFloat r = ((hex>>16)&0xFF)/255.0;
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.0];
    return color;
}

+ (CGFloat)ht_colorComponentFrom: (NSString *) string start: (NSUInteger) start length: (NSUInteger) length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

+ (UIColor *)ht_colorWithHexString:(NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self ht_colorComponentFrom: colorString start: 0 length: 1];
            green = [self ht_colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self ht_colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self ht_colorComponentFrom: colorString start: 0 length: 1];
            red   = [self ht_colorComponentFrom: colorString start: 1 length: 1];
            green = [self ht_colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self ht_colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self ht_colorComponentFrom: colorString start: 0 length: 2];
            green = [self ht_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self ht_colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            alpha = [self ht_colorComponentFrom: colorString start: 0 length: 2];
            red   = [self ht_colorComponentFrom: colorString start: 2 length: 2];
            green = [self ht_colorComponentFrom: colorString start: 4 length: 2];
            blue  = [self ht_colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            return nil;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

@end
