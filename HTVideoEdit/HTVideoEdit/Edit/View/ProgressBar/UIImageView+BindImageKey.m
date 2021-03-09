//
//  UIImageView+BindImageKey.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "UIImageView+BindImageKey.h"
#import <objc/runtime.h>

static char KEY_INDEX_NUMBER;

@implementation UIImageView(KKFrameImageProgressBar)

- (NSString *)indexKey {
    return (NSString *)objc_getAssociatedObject(self, &KEY_INDEX_NUMBER);
}
- (void)setIndexKey:(NSString *)indexKey {
    objc_setAssociatedObject(self, &KEY_INDEX_NUMBER, indexKey, OBJC_ASSOCIATION_RETAIN);
}

@end
