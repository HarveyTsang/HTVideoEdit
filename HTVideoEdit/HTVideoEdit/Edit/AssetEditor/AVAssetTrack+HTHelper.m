//
//  AVAssetTrack+HTHelper.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/16.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "AVAssetTrack+HTHelper.h"

@implementation AVAssetTrack (HTHelper)

- (CGSize)ht_renderSize {
    CGSize naturalSize = self.naturalSize;
    HTVideoRotation rotation = [self ht_rotation];
    switch (rotation) {
        case HTVideoRotation90:
        case HTVideoRotation270:
            return CGSizeMake(naturalSize.height, naturalSize.width);
        case HTVideoRotation0:
        case HTVideoRotation180:
            return naturalSize;
    }
}

- (HTVideoRotation)ht_rotation {
    // LandscapeLeft
    HTVideoRotation degress = HTVideoRotation0;
    CGAffineTransform t = self.preferredTransform;
    if (t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0) {
        // Portrait
        degress = HTVideoRotation90;
    } else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0) {
        // LandscapeRight
        degress = HTVideoRotation180;
    } else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0) {
        // PortraitUpsideDown
        degress = HTVideoRotation270;
    }
    return degress;
}

- (CGAffineTransform)ht_transformFitBox:(CGSize)boxSize {
    CGAffineTransform transform = [self ht_transform];
    CGSize renderSize = [self ht_renderSize];
    CGFloat renderRatio = renderSize.width / renderSize.height;
    CGFloat boxRatio = boxSize.width / boxSize.height;
    CGFloat h = 0, w = 0, tx = 0, ty = 0;
    if (renderRatio > boxRatio) {
        w = boxSize.width;
        h = (int)(w / renderRatio);
        ty = (int)((boxSize.height - h) / 2.0);
    } else {
        h = (int)boxSize.height;
        w = (int)(h * renderRatio);
        tx = (int)((boxSize.width - w) / 2.0);
    }
    CGAffineTransform scale = CGAffineTransformMakeScale(w / renderSize.width, w / renderSize.width);
    transform = CGAffineTransformConcat(transform, scale);
    CGAffineTransform translate = CGAffineTransformMakeTranslation(tx, ty);
    transform = CGAffineTransformConcat(transform, translate);
    
    return transform;
}

- (CGAffineTransform)ht_transformFillBox:(CGSize)boxSize {
    CGAffineTransform transform = [self ht_transform];
    CGSize renderSize = [self ht_renderSize];
    CGFloat renderRatio = renderSize.width / renderSize.height;
    CGFloat boxRatio = boxSize.width / boxSize.height;
    CGFloat h = 0, w = 0, tx = 0, ty = 0;
    if (renderRatio > boxRatio) {
        h = boxSize.height;
        w = h * renderRatio;
        tx = - (w - boxSize.width) / 2.0;
    } else {
        w = boxSize.width;
        h = w / renderRatio;
        ty = - (h - boxSize.height) / 2.0;
    }
    CGAffineTransform scale = CGAffineTransformMakeScale(w / renderSize.width, w / renderSize.width);
    transform = CGAffineTransformConcat(transform, scale);
    CGAffineTransform translate = CGAffineTransformMakeTranslation(tx, ty);
    return CGAffineTransformConcat(transform, translate);
}
- (CGAffineTransform)ht_transform {
    HTVideoRotation rotation = [self ht_rotation];
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGAffineTransform translateToCenter = CGAffineTransformIdentity;
    switch (rotation) {
        case HTVideoRotation90: {
            translateToCenter = CGAffineTransformMakeTranslation(self.naturalSize.height, 0.0);
            transform = CGAffineTransformRotate(translateToCenter, M_PI_2);
        }
            break;
        case HTVideoRotation180: {
            translateToCenter = CGAffineTransformMakeTranslation(self.naturalSize.width, self.naturalSize.height);
            transform = CGAffineTransformRotate(translateToCenter, M_PI);
        }
            break;
        case HTVideoRotation270: {
            translateToCenter = CGAffineTransformMakeTranslation(0.0, self.naturalSize.width);
            transform = CGAffineTransformRotate(translateToCenter, M_PI_2 + M_PI);
        }
            break;
        default:
            break;
    }
    
    return transform;
}

@end
