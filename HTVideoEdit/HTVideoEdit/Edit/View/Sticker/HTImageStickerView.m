//
//  HTImageStickerView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/2.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTImageStickerView.h"

@interface HTImageStickerView ()

@property (nonatomic, strong) CALayer *imageLayer;

@end

@implementation HTImageStickerView

- (instancetype)initWithImageURL:(NSURL *)imageURL {
    CGSize imageSize = [HTImageStickerView getImageSizeFromURL:imageURL];
    CGRect frame = CGRectMake(0, 0, 100, 100);
    if (imageSize.width > 0 && imageSize.height > 0) {
        frame.size.height = (imageSize.height / imageSize.width) * frame.size.width;
    }
    if (self = [super initWithFrame:frame]) {
        _imageLayer = [CALayer layer];
        [self.layer addSublayer:_imageLayer];
        self.URL = imageURL;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.imageLayer.frame = self.bounds;
    [CATransaction commit];
}

- (NSArray<NSString *> *)actionTypes {
    return @[
        HTStickerHightlightViewActionTypeRemove,
        HTStickerHightlightViewActionTypeScaleAndRotate,
    ];
}

- (CALayer *)layerWithScale:(CGFloat)scale {
    CALayer *layer = [super layerWithScale:scale];
    
    CALayer *imageLayer = [CALayer new];
    imageLayer.frame = CGRectMake(0, 0, layer.frame.size.width, layer.frame.size.height);
    [layer addSublayer:imageLayer];
    imageLayer.contents = _imageLayer.contents;
    imageLayer.affineTransform = _imageLayer.affineTransform;
    
    if ([_imageLayer animationForKey:@"gif"]) {
        [imageLayer addAnimation:[_imageLayer animationForKey:@"gif"] forKey:@"gif"];
    }
    
    return layer;
}

- (void)setURL:(NSURL *)URL {
    if (!URL) return;
    _URL = URL;
    CGSize imageSize = [HTImageStickerView getImageSizeFromURL:URL];
    CGRect newBounds = self.bounds;
    if (imageSize.width > 0 && imageSize.height > 0) {
        newBounds.size.height = (imageSize.height / imageSize.width) * newBounds.size.width;
    }
    self.bounds = newBounds;
    _imageLayer.contents = nil;
    [_imageLayer removeAnimationForKey:@"gif"];
    [self addContentToLayer:_imageLayer fromURL:URL];
}

- (void)addContentToLayer:(CALayer *)layer fromURL:(NSURL *)URL {
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)URL, NULL);
    size_t count = CGImageSourceGetCount(src);
    if (count == 1) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(src, 0, nil);
        layer.contents = (__bridge id)image;
        CFRelease(image);
    } else {
        float time = 0;
        NSMutableArray *frames = @[].mutableCopy;
        NSMutableArray *tempTimes = @[].mutableCopy;
        float frameDuration  = 0.1;
        for (int i = 0; i < count; i++) {
            CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, i, NULL);
            CFDictionaryRef gifProperties = CFDictionaryGetValue(cfFrameProperties, kCGImagePropertyGIFDictionary);
            NSNumber *unclampedDelayTime = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (unclampedDelayTime) {
                frameDuration = unclampedDelayTime.floatValue;
            } else {
                NSNumber *gifDelayTime = (__bridge id)CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
                if (gifDelayTime) {
                    frameDuration = gifDelayTime.floatValue;
                }
            }
            if (frameDuration < 0.011) {
                frameDuration = 0.1;
            }
            [tempTimes addObject:[NSNumber numberWithFloat:frameDuration]];
            CFRelease(cfFrameProperties);
            CGImageRef frame = CGImageSourceCreateImageAtIndex(src, i, nil);
            [frames addObject:(__bridge id)frame];
            time += frameDuration;
            CFRelease(frame);
        }
        NSMutableArray *times = @[].mutableCopy;
        float keyTime = 0.0;
        for (NSNumber *duration in tempTimes) {
            keyTime += (duration.floatValue / time);
            [times addObject:[NSNumber numberWithFloat:keyTime]];
        }
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
        animation.duration = time;
        animation.repeatCount = HUGE_VALF;
        animation.beginTime = AVCoreAnimationBeginTimeAtZero;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        animation.values = frames;
        animation.keyTimes = times;
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        animation.calculationMode = kCAAnimationDiscrete;
        
        if (frames.count > 0) layer.contents = frames[0];
        
        [layer addAnimation:animation forKey:@"gif"];
    }
    CFRelease(src);
}

+ (CGSize)getImageSizeFromURL:(NSURL *)URL {
    CGSize size = CGSizeZero;
    CGImageSourceRef src = CGImageSourceCreateWithURL((__bridge CFURLRef)URL, NULL);
    size_t count = CGImageSourceGetCount(src);
    if (count > 0) {
        CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(src, 0, NULL);
        NSNumber *width = CFDictionaryGetValue(cfFrameProperties, kCGImagePropertyPixelWidth);
        NSNumber *height = CFDictionaryGetValue(cfFrameProperties, kCGImagePropertyPixelHeight);
        size = CGSizeMake(width.integerValue, height.integerValue);
        CFRelease(cfFrameProperties);
    }
    CFRelease(src);
    return size;
}

@end
