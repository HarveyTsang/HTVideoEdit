//
//  HTTextStickerAttributePicker.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/3.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTextStickerAttributePicker.h"
#import "HTColorCell.h"
#import "HTFontCell.h"
#import "UIColor+Hex.h"
#import "HTFontInfo.h"

static NSString *const kFontCellID = @"HTColorCellID";
static NSString *const kColorCellID = @"HTFontCellID";

@interface HTTextStickerAttributePicker ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray<NSString *> *colorHexStrs;

@end

@implementation HTTextStickerAttributePicker

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor ht_primaryColor];
        _colorHexStrs = @[
            @"000000", @"333333", @"999999", @"FFFFFF", @"E93F2D", @"E2355A", @"F16384",
            @"FF7474", @"FF6E3F", @"F39C12", @"F1C40F", @"F3E5D1", @"FEFF9D", @"FDFF2B",
            @"C4FF30", @"77E118", @"00B300", @"00F3D4", @"88EFE4", @"17B4EB", @"087AED",
            @"4C4EFF", @"2845AF", @"4F348D", @"724CFF", @"9B82FC", @"D181FF", @"FCD1FF",
        ];
        [self setupSubviews];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveFontStatusChangeNotification:) name:HTFontInfoStatusChangeNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(receiveFontProgressNotification:) name:HTFontInfoProgressNotification object:nil];
    }
    return self;
}
- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
- (void)setupSubviews {
    [self addSubview:self.topView];
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self);
        make.height.equalTo(@40);
    }];
    [self addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.trailing.equalTo(self);
        make.top.equalTo(self.topView.mas_bottom);
    }];
}

- (void)setHidden:(BOOL)hidden {
    [super setHidden:hidden];
    if (!hidden) {
        self.segmentControl.selectedSegmentIndex = 0;
        [self segmentValueChange];
    }
}

#pragma mark - Getter
- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = [UIColor ht_primaryColor];
        
        UIColor *lineColor = [UIColor ht_lineColor];
        UIView *topLine = [UIView new];
        topLine.backgroundColor = lineColor;
        [_topView addSubview:topLine];
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.trailing.equalTo(_topView);
            make.height.equalTo(@0.5);
        }];
        UIView *bottomLine = [UIView new];
        bottomLine.backgroundColor = lineColor;
        [_topView addSubview:bottomLine];
        [bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.equalTo(_topView);
            make.height.equalTo(@0.5);
        }];
        
        [_topView addSubview:self.segmentControl];
        [self.segmentControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_topView);
        }];
    }
    return _topView;
}

- (UISegmentedControl *)segmentControl {
    if (!_segmentControl) {
        _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"颜色", @"字体"]];
        [_segmentControl addTarget:self action:@selector(segmentValueChange) forControlEvents:UIControlEventValueChanged];
    }
    return _segmentControl;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor ht_primaryColor];
        [_collectionView registerClass:HTColorCell.class forCellWithReuseIdentifier:kColorCellID];
        [_collectionView registerClass:HTFontCell.class forCellWithReuseIdentifier:kFontCellID];
    }
    return _collectionView;
}

- (HTFontCell *)findFontCellByFontName:(NSString *)fontName {
    if (self.segmentControl.selectedSegmentIndex != 1) return nil;
    NSUInteger index = NSNotFound;
    for (int i = 0; i < HTFontInfo.sharedFonts.count; i++) {
        if ([HTFontInfo.sharedFonts[i].name isEqualToString:fontName]) {
            index = i;
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    HTFontCell *cell = (HTFontCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
    return cell;
}

#pragma mark - Actions
- (void)segmentValueChange {
    [self.collectionView reloadData];
    NSIndexPath *indexPath = nil;
    if (_segmentControl.selectedSegmentIndex == 0) {
        NSString *hexStr = [_color ht_hexStringWithoutAlpha];
        indexPath = [NSIndexPath indexPathForItem:[_colorHexStrs indexOfObject:hexStr] inSection:0];
    } else {
        NSUInteger index = NSNotFound;
        for (int i = 0; i < HTFontInfo.sharedFonts.count; i++) {
            if ([HTFontInfo.sharedFonts[i].name isEqualToString:_fontName]) {
                index = i;
                break;
            }
        }
        indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    }
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

- (void)receiveFontStatusChangeNotification:(NSNotification *)notification {
    if (self.segmentControl.selectedSegmentIndex != 1) return;
    NSString *fontName = notification.userInfo[@"fontName"];
    HTFontStatus status = [notification.userInfo[@"status"] integerValue];
    HTFontCell *cell = [self findFontCellByFontName:fontName];
    if (cell) {
        [cell updateWithStatus:status];
    }
}

- (void)receiveFontProgressNotification:(NSNotification *)notification {
    if (self.segmentControl.selectedSegmentIndex != 1) return;
    NSString *fontName = notification.userInfo[@"fontName"];
    double progress = [notification.userInfo[@"progress"] doubleValue];
    HTFontCell *cell = [self findFontCellByFontName:fontName];
    if (cell) {
        [cell updateWithProgress:progress];
    }
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.segmentControl.selectedSegmentIndex == 0 ? _colorHexStrs.count : HTFontInfo.sharedFonts.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        HTColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kColorCellID forIndexPath:indexPath];
        NSString *hexStr = _colorHexStrs[indexPath.item];
        UIColor *color = [UIColor ht_colorWithHexString:hexStr];
        cell.colorView.backgroundColor = color;
        return cell;
    } else {
        HTFontCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kFontCellID forIndexPath:indexPath];
        HTFontInfo *fontInfo = HTFontInfo.sharedFonts[indexPath.item];
        [cell setupWithFontInfo:fontInfo];
        return cell;
    }
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        return CGSizeMake(40, 40);
    } else {
        return CGSizeMake((self.frame.size.width - 30) / 2, 40);
    }
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(textStickerAttributePicker:didSelectColor:)]) {
            NSString *hexStr = _colorHexStrs[indexPath.item];
            UIColor *color = [UIColor ht_colorWithHexString:hexStr];
            _color = color;
            [self.delegate textStickerAttributePicker:self didSelectColor:color];
        }
    } else {
        HTFontInfo *fontInfo = HTFontInfo.sharedFonts[indexPath.item];
        if (fontInfo.status != HTFontStatusDownloaded) return;
        if (self.segmentControl.selectedSegmentIndex == 1 && self.delegate && [self.delegate respondsToSelector:@selector(textStickerAttributePicker:didSelectFont:)]) {
            _fontName = fontInfo.name;
            [self.delegate textStickerAttributePicker:self didSelectFont:_fontName];
        }
    }
}
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.segmentControl.selectedSegmentIndex == 0) return YES;
    
    HTFontInfo *fontInfo = HTFontInfo.sharedFonts[indexPath.item];
    if (fontInfo.status == HTFontStatusInit || fontInfo.status == HTFontStatusDownloadFailed) {
        [fontInfo download];
    }
    return fontInfo.status == HTFontStatusDownloaded;
}

@end
