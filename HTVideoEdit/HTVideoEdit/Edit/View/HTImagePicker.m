//
//  HTImagePicker.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/3/6.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTImagePicker.h"
#import "HTImageCell.h"

@interface HTImagePicker ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSArray *URLs;

@end

@implementation HTImagePicker

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        NSArray *names = @[@"dog.png", @"dog.gif"];
        NSMutableArray *array = @[].mutableCopy;
        for (NSString *name in names) {
            NSURL *url = [NSBundle.mainBundle URLForResource:name withExtension:nil];
            if (url) [array addObject:url];
        }
        _URLs = array;
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat itemW = floor((self.bounds.size.width-40)/3);
    flowLayout.itemSize = CGSizeMake(itemW, itemW);
    flowLayout.minimumInteritemSpacing = 10;
    flowLayout.minimumLineSpacing = 10;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor ht_primaryColor];
    [_collectionView registerClass:HTImageCell.class forCellWithReuseIdentifier:@"CellId"];
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [closeBtn setImage:[UIImage imageNamed:@"edit_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnAction) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.equalTo(@30);
        make.top.trailing.offset(0);
    }];
}

- (void)setURL:(NSURL *)URL {
    _URL = URL;
    NSUInteger index = [_URLs indexOfObject:URL];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    [_collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredVertically];
}

#pragma mark - Actions
- (void)closeBtnAction {
    if (self.didClickClose) self.didClickClose(self);
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _URLs.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSURL *url = _URLs[indexPath.item];
    HTImageCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CellId" forIndexPath:indexPath];
    NSData *data = [NSData dataWithContentsOfURL:url];
    UIImage *image = [UIImage imageWithData:data];
    cell.imageView.image = image;
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_didSelect) {
        _didSelect(_URLs[indexPath.item]);
    }
}

@end
