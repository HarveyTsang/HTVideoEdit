//
//  HTFontInfo.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/4.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const HTFontInfoStatusChangeNotification;
extern NSString *const HTFontInfoProgressNotification;

typedef NS_ENUM(NSUInteger, HTFontStatus) {
    HTFontStatusInit,
    HTFontStatusWaiting,
    HTFontStatusDownloading,
    HTFontStatusDownloaded,
    HTFontStatusDownloadFailed,
};

@interface HTFontInfo : NSObject

@property (nonatomic, readonly) NSString *name;

@property (nonatomic, readonly) NSString *zhName;

@property (nonatomic, readonly) NSString *imageName;

@property (nonatomic, readonly) HTFontStatus status;

@property (nonatomic, readonly) float progress;// 0.0~100.0

+ (NSArray<HTFontInfo *> *)sharedFonts;

- (void)download;

@end

NS_ASSUME_NONNULL_END
