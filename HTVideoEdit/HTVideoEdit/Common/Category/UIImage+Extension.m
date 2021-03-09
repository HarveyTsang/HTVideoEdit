//
//  UIImage+Extension.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/22.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "UIImage+Extension.h"
#import <Accelerate/Accelerate.h>
@implementation UIImage (Extension)

+ (UIImage *)ht_createImageWithColor:(UIColor *)color{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}

@end
