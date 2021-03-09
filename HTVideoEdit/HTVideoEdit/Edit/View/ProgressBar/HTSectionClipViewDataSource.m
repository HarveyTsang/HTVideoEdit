//
//  HTSectionClipViewDataSource.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTSectionClipViewDataSource.h"
#import "UIImageView+BindImageKey.h"
#import "UIImage+Extension.h"

#define kQueryKey(index) [NSString stringWithFormat:@"%p-%lu", self, (unsigned long)index]

@interface HTSectionClipViewDataSource ()

@property (nonatomic, strong) NSMutableArray<UIImage *> *frameImages;
@property (nonatomic, strong) NSMapTable<NSString *, UIImageView *> *indexViewMap;
@property (nonatomic, strong) AVAssetImageGenerator *imageGenerator;
@property (nonatomic, assign) NSUInteger imageCount;
@property (nonatomic, assign) HTSectionVisualRange visualRange;

@end

@implementation HTSectionClipViewDataSource

- (instancetype)initWithAsset:(AVAsset *)asset {
    
    if ([asset tracksWithMediaType:AVMediaTypeVideo].count == 0) return nil;
    
    if (self = [super init]) {
        _imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        _imageCount = ceil(CMTimeGetSeconds(asset.duration)/kFrameDuration);
        _frameImages = [NSMutableArray arrayWithCapacity:_imageCount];
        _indexViewMap = [NSMapTable mapTableWithKeyOptions:NSPointerFunctionsCopyIn valueOptions:NSPointerFunctionsWeakMemory];
        
        self.trimTimeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
        [self fetchThumbnailFrameImages];
    }
    return self;
}

- (void)queryImageAtIndex:(NSUInteger)index forImageView:(UIImageView *)imageView {
    UIImage *image = nil;
    @synchronized(self) {
        if (self.frameImages.count > index) {
            image = self.frameImages[index];
        }
    }
    NSString *key = kQueryKey(index);//[self keyWithIndex:index];
    if (!image) {
        @synchronized(self) {
            [_indexViewMap setObject:imageView forKey:key];
        }
    }
    imageView.image = image;
    imageView.indexKey = key;
}

- (void)fetchThumbnailFrameImages {
    if (_imageCount < 1) return;
    
    NSMutableArray *times = @[].mutableCopy;
    for (int i = 0; i < _imageCount; i++) {
        CMTime time = CMTimeMakeWithSeconds(i*kFrameDuration, 100);
        [times addObject:[NSValue valueWithCMTime:time]];
    }
    
    _imageGenerator.appliesPreferredTrackTransform = YES;
    _imageGenerator.maximumSize = [self imageMaxSize];
    _imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    _imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    __weak HTSectionClipViewDataSource *ws = self;
    [_imageGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (!ws) return;
        
        UIImage *uiImage = nil;
        if (image && !error) {
            uiImage = [UIImage imageWithCGImage:image];
        }
        else {
            uiImage = [UIImage ht_createImageWithColor:[UIColor blackColor]];
            NSLog(@"generate image fail:%@", error.localizedDescription);
        }
        @synchronized(ws) {
            [ws.frameImages addObject:uiImage];
        }
        NSString *key = kQueryKey(ws.frameImages.count-1);
        UIImageView *imageView = [ws.indexViewMap objectForKey:key];
        if (imageView && [imageView.indexKey isEqualToString:key]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = uiImage;
            });
        }
        @synchronized(ws) {
            [ws.indexViewMap removeObjectForKey:key];
        }
    }];
}

- (CGSize)imageMaxSize {
    CGSize naturalSize = [_imageGenerator.asset tracksWithMediaType:AVMediaTypeVideo][0].naturalSize;
    CGSize targetSize = CGSizeMake(80, 80);
    CGFloat originalRatio = naturalSize.width / naturalSize.height;
    CGFloat targetRatio = targetSize.width / targetSize.height;
    CGSize maxSize = CGSizeZero;
    if (originalRatio > targetRatio) {
        maxSize.height = targetSize.height;
        maxSize.width = maxSize.height * originalRatio;
    }
    else {
        maxSize.width = targetSize.width;
        maxSize.height = maxSize.width / originalRatio;
    }
    return maxSize;
}

+ (CGSize)itemSize {
    return CGSizeMake(40.0, 40.0);
}

#pragma mark - getter
- (CGFloat)totalLength {
    return 40.0 * CMTimeGetSeconds(self.imageGenerator.asset.duration) / kFrameDuration;
}

#pragma mark - setter
- (void)setTrimTimeRange:(CMTimeRange)trimTimeRange {
    CMTime endTime = CMTimeAdd(trimTimeRange.start, trimTimeRange.duration);
    if (CMTimeCompare(_imageGenerator.asset.duration, endTime) == -1) return;
    
    _trimTimeRange = trimTimeRange;
    
    CGFloat totalLength = [self totalLength];
    CGFloat totalSeconds = CMTimeGetSeconds(self.imageGenerator.asset.duration);
    CGFloat start = totalLength*CMTimeGetSeconds(_trimTimeRange.start)/totalSeconds;
    CGFloat end = totalLength*CMTimeGetSeconds(endTime)/totalSeconds;
    _visualRange = (HTSectionVisualRange){
        start,
        end-start
    };
}


@end
