//
//  KKVideoEditProgressView.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTSectionClipScrollView.h"
#import "HTSectionClipView.h"
#import "UIView+Frame.h"

@interface HTSectionClipScrollView ()

@property (nonatomic, strong)NSArray<NSMutableDictionary<NSNumber *, UIView *> *> *visualCells;
@property (nonatomic, assign) NSUInteger numberOfSection;
@property (nonatomic, assign) BOOL needReload;
@property (nonatomic, strong) NSMutableSet *reusePool;
@property (nonatomic, strong) NSArray<HTSectionClipView *> *sectionViews;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger currentSelectSection;

@end

@implementation HTSectionClipScrollView

@dynamic delegate;

- (instancetype)init {
    if (self = [super init]) {
        _needReload = YES;
        _currentSelectSection = -1;
        _itemSize = CGSizeMake(40, 40);
        [self setupInsertButton];
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return self;
}

- (void)setupInsertButton {
    _headInsertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_headInsertButton setImage:[UIImage imageNamed:@"edit_add_video"] forState:UIControlStateNormal];
    [self addSubview:_headInsertButton];
    
    _tailInsertButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_tailInsertButton setImage:[UIImage imageNamed:@"edit_add_video"] forState:UIControlStateNormal];
    [self addSubview:_tailInsertButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self layoutScrollView];
}

- (void)layoutScrollView {
    if (_needReload) {
        _needReload = NO;
        
        _numberOfSection = 0;
        if ([self.dataSource respondsToSelector:@selector(numberOfSection)]) {
            _numberOfSection = [self.dataSource numberOfSection];
        }
        
        for (HTSectionClipView *clipView in self.sectionViews) {
            [clipView removeFromSuperview];
        }
        self.sectionViews = nil;
        _currentSelectSection = -1;
        
        NSMutableArray *sectionViews = @[].mutableCopy;
        CGFloat startX = 0.0;
        CGFloat y = (self.frame.size.height-self.itemSize.height)/2.0;
        NSMutableArray *visualCells = @[].mutableCopy;
        for (int i = 0; i < _numberOfSection; i++) {
            CGFloat totalLength = 0.0;
            if ([self.dataSource respondsToSelector:@selector(totalLengthOfSection:)]) {
                totalLength = [self.dataSource totalLengthOfSection:i];
            }
            
            HTSectionClipView *sectionView = [[HTSectionClipView alloc] initWithTotalLength:totalLength];
            sectionView.itemWidth = self.itemSize.width;
            HTSectionVisualRange visualRange = (HTSectionVisualRange){0.0, 0.0};
            if ([self.dataSource respondsToSelector:@selector(visualRangeOfSection:)]) {
                visualRange = [self.dataSource visualRangeOfSection:i];
            }
            sectionView.visualRange = visualRange;
            sectionView.frame = CGRectMake(startX, y, visualRange.length, self.itemSize.height);
            startX += visualRange.length;
            [self.contentView addSubview:sectionView];
            [sectionViews addObject:sectionView];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSectionView:)];
            [sectionView addGestureRecognizer:tap];
            
            [visualCells addObject:@{}.mutableCopy];
        }
        self.visualCells = visualCells.copy;
        self.sectionViews = sectionViews.copy;
        self.contentSize = CGSizeMake(startX, self.bounds.size.height);
        self.contentView.frame = CGRectMake(0.0, 0.0, self.contentSize.width, self.contentSize.height);
        
        _headInsertButton.frame = CGRectMake(-(self.itemSize.width+2.0), y, self.itemSize.width, self.itemSize.height);
        _tailInsertButton.frame = CGRectMake(startX+2.0, y, self.itemSize.width, self.itemSize.height);
    }
    CGRect scrollViewVisualRect = CGRectMake(self.contentOffset.x, 0, self.bounds.size.width, self.bounds.size.height);
    for (NSUInteger i = 0; i < self.sectionViews.count; i++) {
        HTSectionClipView *sectionView = self.sectionViews[i];
        CGRect sectionVisualRect = CGRectIntersection(scrollViewVisualRect, sectionView.frame);
        NSRange range = NSMakeRange(0, 0);
        if (!CGRectIsNull(sectionVisualRect)) {
            range = [sectionView visualRangeWithRect:sectionVisualRect];
            for (NSUInteger j = range.location; j < range.location+range.length; j++) {
                UIView *cell = [self.visualCells[i] objectForKey:@(j)];
                if (cell == nil) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:j inSection:i];
                    cell = [self.dataSource cellAtIndexPath:indexPath];
                    [self.visualCells[i] setObject:cell forKey:@(j)];
                    [sectionView.contentView addSubview:cell];
                }
                cell.frame = CGRectMake(j*sectionView.itemWidth-sectionView.visualRange.start, 0.0, self.itemSize.width, self.itemSize.height);
            }
        }
        NSArray *allVisibleCells = self.visualCells[i].allKeys;
        for (NSNumber *numb in allVisibleCells) {
            if (!NSLocationInRange(numb.integerValue, range)) {
                UIView *cell = [self.visualCells[i] objectForKey:numb];
                [self.reusePool addObject:cell];
                [self.visualCells[i] removeObjectForKey:numb];
                [cell removeFromSuperview];
            }
        }
    }
}

#pragma mark - Action
- (void)tapSectionView:(UITapGestureRecognizer *)sender {
    NSUInteger index = [self.sectionViews indexOfObject:(HTSectionClipView *)sender.view];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sectionClipScrollView:didClickSection:)]) {
        [self.delegate sectionClipScrollView:self didClickSection:index];
    }
}

#pragma mark - Private
- (void)endChangeVisualRange {
    CGSize contentSize = self.contentSize;
    contentSize.width = CGRectGetMaxX(self.sectionViews.lastObject.frame);

    [UIView animateWithDuration:0.25 animations:^{
        self.contentSize = contentSize;
    }];
}

- (NSMutableSet *)reusePool {
    if (!_reusePool) {
        _reusePool = [NSMutableSet set];
    }
    return _reusePool;
}

#pragma mark - Public
- (CGRect)frameOfSection:(NSUInteger)section {
    return self.sectionViews[section].frame;
}

- (void)selectSection:(NSUInteger)section {
    if (section >= _numberOfSection || section == _currentSelectSection) return;
    if (_currentSelectSection >= 0) self.sectionViews[_currentSelectSection].selected = NO;
    _currentSelectSection = section;
    self.sectionViews[section].selected = YES;
    [self.contentView bringSubviewToFront:self.sectionViews[section]];
}

- (void)unselect {
    if (_currentSelectSection < 0) return;
    self.sectionViews[_currentSelectSection].selected = NO;
    _currentSelectSection = -1;
}

- (HTTimeRangeView *)timeRangeViewOfCurrentSelectSection {
    if (_currentSelectSection < 0) return nil;
    return _sectionViews[_currentSelectSection].timeRangeView;
}

- (void)changeVisualRange:(HTSectionVisualRange)visualRange atSection:(NSUInteger)section needChangeContentOffset:(BOOL)needChangeOffset {
    CGRect oldFrame = self.sectionViews[section].frame;
    CGFloat offset = visualRange.length-oldFrame.size.width;
    oldFrame.size.width = visualRange.length;
    self.sectionViews[section].frame = oldFrame;
    self.sectionViews[section].visualRange = visualRange;
    
    for (NSUInteger i = section+1; i < self.sectionViews.count; i++) {
        self.sectionViews[i].x += offset;
    }
    CGSize contentSize = self.contentSize;
    contentSize.width += offset;
    self.contentSize = contentSize;
    self.contentView.width += offset;
    _tailInsertButton.x += offset;
    
    if (needChangeOffset) {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.x += offset;
        self.contentOffset = contentOffset;
    }
}

- (void)editVisualRangeStart:(CGFloat)start atSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    HTSectionVisualRange visualRange = self.sectionViews[section].visualRange;
    CGFloat offset = start - visualRange.start;
    CGRect frame = self.sectionViews[section].frame;
    frame.origin.x += offset;
    frame.size.width -= offset;
    self.sectionViews[section].frame = frame;
    visualRange.start = start;
    self.sectionViews[section].visualRange = visualRange;
    
    for (NSUInteger i = 0; i < section; i++) {
        self.sectionViews[i].x += offset;
    }
    _headInsertButton.x += offset;
    if (needUpdateContentOffset) {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.x += offset;
        self.contentOffset = contentOffset;
    }
    [self setNeedsLayout];
}

- (void)editVisualRangeLength:(CGFloat)length atSection:(NSUInteger)section needUpdateContentOffset:(BOOL)needUpdateContentOffset {
    HTSectionVisualRange visualRange = self.sectionViews[section].visualRange;
    CGFloat offset = length - visualRange.length;
    CGRect frame = self.sectionViews[section].frame;
    frame.size.width += offset;
    self.sectionViews[section].frame = frame;
    visualRange.length = length;
    self.sectionViews[section].visualRange = visualRange;
    
    for (NSUInteger i = section+1; i < self.sectionViews.count; i++) {
        self.sectionViews[i].x += offset;
    }
    _tailInsertButton.x += offset;
    if (needUpdateContentOffset) {
        CGPoint contentOffset = self.contentOffset;
        contentOffset.x += offset;
        self.contentOffset = contentOffset;
    }
    [self setNeedsLayout];
}

- (void)endEditVisualRange {
    CGFloat startX = 0.0;
    CGFloat y = (self.frame.size.height-self.itemSize.height)/2.0;
    for (int i = 0; i < self.sectionViews.count; i++) {
        self.sectionViews[i].x = startX;
        startX += self.sectionViews[i].frame.size.width;
    }
    self.contentView.width = startX;
    CGSize contentSize = self.contentSize;
    contentSize.width = startX;
    self.contentSize = contentSize;
    _headInsertButton.frame = CGRectMake(-(self.itemSize.width+2.0), y, self.itemSize.width, self.itemSize.height);
    _tailInsertButton.frame = CGRectMake(startX+2.0, y, self.itemSize.width, self.itemSize.height);
    
}

- (UIView *)dequeueReusableCell {
    UIView *reuseCell = nil;
    for (UIView *cell in self.reusePool) {
        reuseCell = cell;
        break;
    }
    if (reuseCell) {
        [self.reusePool removeObject:reuseCell];
    }
    return reuseCell;
}

- (void)reloadData {
    _needReload = YES;
    [self setNeedsLayout];
}

@end
