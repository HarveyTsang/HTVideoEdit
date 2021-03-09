//
//  KKVideoEditProgressView.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HTTimeRangeView.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct {
    CGFloat start;
    CGFloat length;
} HTSectionVisualRange;

@protocol HTSectionClipScrollViewDataSource <NSObject>

- (NSUInteger)numberOfSection;

- (CGFloat)totalLengthOfSection:(NSUInteger)section;

- (HTSectionVisualRange)visualRangeOfSection:(NSUInteger)section;

- (UIView *)cellAtIndexPath:(NSIndexPath *)indexPath;

@end

@class HTSectionClipScrollView;
@protocol HTSectionClipScrollViewDelegate <UIScrollViewDelegate>

@optional
- (void)sectionClipScrollView:(HTSectionClipScrollView *)scrollView didClickSection:(NSUInteger)section;

@end

@class HTSectionClipView;

@interface HTSectionClipScrollView : UIScrollView

@property (nonatomic, strong) UIButton *headInsertButton;
@property (nonatomic, strong) UIButton *tailInsertButton;
@property (nonatomic, weak, nullable) id<HTSectionClipScrollViewDataSource> dataSource;
@property (nonatomic, weak, nullable) id<HTSectionClipScrollViewDelegate> delegate;
@property (nonatomic, assign) CGSize itemSize;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, readonly, nullable) HTTimeRangeView *timeRangeViewOfCurrentSelectSection;

- (UIView *)dequeueReusableCell;

- (void)reloadData;

- (void)changeVisualRange:(HTSectionVisualRange)visualRange atSection:(NSUInteger)section needChangeContentOffset:(BOOL)needChangeOffset;

- (void)editVisualRangeStart:(CGFloat)start atSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)editVisualRangeLength:(CGFloat)length atSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset;

- (void)endEditVisualRange;

- (CGRect)frameOfSection:(NSUInteger)section;

- (void)selectSection:(NSUInteger)section;

- (void)unselect;

@end

NS_ASSUME_NONNULL_END

