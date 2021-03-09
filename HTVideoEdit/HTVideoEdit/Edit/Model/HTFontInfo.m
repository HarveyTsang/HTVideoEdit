//
//  HTFontInfo.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/4.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTFontInfo.h"
#import <CoreText/CoreText.h>

NSString *const HTFontInfoStatusChangeNotification = @"HTFontInfoStatusChangeNotification";
NSString *const HTFontInfoProgressNotification = @"HTFontInfoProgressNotification";

typedef bool(^MockDownloadHandler)(CTFontDescriptorMatchingState state, CFDictionaryRef  _Nonnull progressParameter);

@interface HTFontInfo ()

@property (nonatomic, copy) NSString *name;

@property (nonatomic, copy) NSString *zhName;

@property (nonatomic, copy) NSString *imageName;

@property (nonatomic, assign) HTFontStatus status;

@property (nonatomic, assign) float progress;

@end

@implementation HTFontInfo

+ (NSArray<HTFontInfo *> *)sharedFonts {
    static NSArray *sharedFonts = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *names = @[
            @"STKaitiSC-Regular", @"MLingWaiMedium-SC", @"HanziPenSC-W3",
            @"HannotateSC-W5", @"DFWaWaSC-W5", @"STXingkaiSC-Light",
        ];
        NSArray *zhNames = @[
            @"楷体-简 细体", @"凌慧体-简 中黑体", @"翩翩体-简 常规体",
            @"手札体-简 常规体", @"娃娃体-简 常规体", @"行楷-简 细体",
        ];
        NSMutableArray *array = @[].mutableCopy;
        for (int i = 0; i < names.count; i++) {
            NSString *name = names[i];
            HTFontInfo *font = [[HTFontInfo alloc] init];
            font.name = name;
            font.zhName = zhNames[i];
            UIFont *uiFont = [UIFont fontWithName:name size:12.];
            if (uiFont && ([uiFont.fontName compare:name] == NSOrderedSame || [uiFont.familyName compare:name] == NSOrderedSame)) {
                font.status = HTFontStatusDownloaded;
            } else {
                font.status = HTFontStatusInit;
            }
            [array addObject:font];
        }
        sharedFonts = array;
    });
    return sharedFonts;
}

- (void)download {
    if (_status == HTFontStatusDownloaded) return;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionaryWithObjectsAndKeys:_name, kCTFontNameAttribute, nil];
    CTFontDescriptorRef desc = CTFontDescriptorCreateWithAttributes((__bridge CFDictionaryRef)attrs);
    NSArray *descs = @[(__bridge id)desc];
    CTFontDescriptorMatchFontDescriptorsWithProgressHandler((__bridge CFArrayRef)descs, NULL, ^bool(CTFontDescriptorMatchingState state, CFDictionaryRef  _Nonnull progressParameter) {
        switch (state) {
            case kCTFontDescriptorMatchingDidBegin:
                self.progress = 0.0;
                self.status = HTFontStatusWaiting;
                [self notifyStatus];
                break;
            case kCTFontDescriptorMatchingWillBeginDownloading:
                self.progress = 0.0;
                self.status = HTFontStatusDownloading;
                [self notifyStatus];
                break;
            case kCTFontDescriptorMatchingDownloading: {
                double progressValue = [[(__bridge NSDictionary *)progressParameter objectForKey:(id)kCTFontDescriptorMatchingPercentage] doubleValue];
                self.progress = progressValue;
                [self notifyProgress];
            }
                break;
            case kCTFontDescriptorMatchingDidFinishDownloading:
                break;
            case kCTFontDescriptorMatchingDidFailWithError:
                self.status = HTFontStatusDownloadFailed;
                [self notifyStatus];
                break;
            case kCTFontDescriptorMatchingDidFinish:
                if (self.status != HTFontStatusDownloadFailed) {
                    self.status = HTFontStatusDownloaded;
                    [self notifyStatus];
                }
                break;
            default:
                break;
        }

        return true;
    });
}

- (void)notifyStatus {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotification *notification = [NSNotification notificationWithName:HTFontInfoStatusChangeNotification object:nil userInfo:@{@"fontName": self.name, @"status": @(self.status)}];
        [NSNotificationCenter.defaultCenter postNotification:notification];
    });
}

- (void)notifyProgress {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSNotification *notification = [NSNotification notificationWithName:HTFontInfoProgressNotification object:nil userInfo:@{@"fontName": self.name, @"progress": @(self.progress)}];
        [NSNotificationCenter.defaultCenter postNotification:notification];
    });
}

@end
