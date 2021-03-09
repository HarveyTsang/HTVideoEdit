//
//  HTVideoEditViewController.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTVideoEditViewController.h"
#import "HTAssetEditor.h"
#import "HTVideoEditToolView.h"
#import "HTVideoEditProgressBar.h"
#import "HTEditPlayerView.h"
#import "APLCompositionDebugView.h"
#import "HTVideoInsertPointHelper.h"
#import "HTAssetPickerController.h"
#import "HTTextStickerView.h"
#import "HTImageStickerView.h"
#import "HTExportProgressView.h"
#import <Photos/Photos.h>

static void *playerItemStatusObserveContext = &playerItemStatusObserveContext;
static void *playerRateObserveContext = &playerRateObserveContext;
static CMTime kMinDuration;

@interface HTVideoEditViewController ()<HTVideoEditProgressBarDelegate, HTVideoEditToolViewDelegate, HTEditPlayerViewDelegate>

@property (nonatomic, strong) HTAssetEditor *editor;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) UIView *navBar;
@property (nonatomic, strong) HTEditPlayerView *playerView;
@property (nonatomic, strong) HTVideoEditProgressBar *progressBar;
@property (nonatomic, strong) HTVideoEditToolView *toolView;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) HTVideoInsertPointHelper *insertTimeHelper;
@property (nonatomic, assign) NSInteger currentEditSection;// -1表示无
@property (nonatomic, assign) CMTimeRange editSectionTimeRange;

@end

@implementation HTVideoEditViewController

+ (void)initialize {
    kMinDuration = CMTimeMake(0.5*30, 30);
}

- (instancetype)init {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample_clip1.m4v" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self = [self initWithAsset:asset];
    return self;
}

- (instancetype)initWithAsset:(AVAsset *)asset {
    if (self = [super init]) {
        _editor = [[HTAssetEditor alloc] initWithAssets:@[asset]];
        _player = [[AVPlayer alloc] initWithPlayerItem:[_editor createPlayItem]];
        [_player addObserver:self forKeyPath:@"currentItem.status" options:NSKeyValueObservingOptionNew context:playerItemStatusObserveContext];
        [_player addObserver:self forKeyPath:@"rate" options:NSKeyValueObservingOptionNew context:playerRateObserveContext];
        __weak typeof(self) ws = self;
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(1, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            [ws playerTimeUpdate:time];
        }];
        _insertTimeHelper = [self createInsertTimeHelper];
        _currentEditSection = -1;
    }
    return self;
}

- (instancetype)initWithAssetPath:(NSString *)path {
    NSURL *url = [NSURL fileURLWithPath:path];
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self = [self initWithAsset:asset];
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self cleanDisk];
}

- (void)dealloc {
    NSLog(@"edit dealloc");
    [_player removeObserver:self forKeyPath:@"currentItem.status"];
    [_player removeObserver:self forKeyPath:@"rate"];
    [_player removeTimeObserver:_timeObserver];
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setupUI {
    self.view.backgroundColor = [UIColor ht_primaryColor];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.navBar];
    [self.navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop);
        } else {
            make.top.equalTo(self.view);
        }
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@40);
    }];
    _toolView = [[HTVideoEditToolView alloc] init];
    _toolView.enableInsertVideo = YES;
    _toolView.enableRemoveVideo = NO;
    _toolView.enableAddSticker = YES;
    _toolView.delegate = self;
    [self.view addSubview:_toolView];
    [_toolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.equalTo(self.view);
        make.height.equalTo(@163);
    }];
    [self.view addSubview:self.progressBar];
    [self.progressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.view);
        make.height.equalTo(@48);
        make.bottom.equalTo(_toolView.mas_top);
    }];
    _playerView = [[HTEditPlayerView alloc] initWithPlayer:_player];
    _playerView.delegate = self;
    [self.view addSubview:_playerView];
    [_playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.navBar.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.progressBar.mas_top);
    }];
    
//    _debugView = [[APLCompositionDebugView alloc] initWithFrame:CGRectMake(10, 92, 400, 300)];
//    [self.view addSubview:_debugView];
//    [_debugView synchronizeToPlayItem:_player.currentItem];
}

- (HTVideoInsertPointHelper *)createInsertTimeHelper {
    NSMutableArray *values = @[].mutableCopy;
    for (int i = 0; i < _editor.assetSegments.count; i++) {
        CMTime insertTime = [_editor insertTimeOfVideoAssetAtIndex:i];
        [values addObject:[NSValue valueWithCMTime:insertTime]];
    }
    [values addObject:[NSValue valueWithCMTime:_editor.composition.duration]];
    return [[HTVideoInsertPointHelper alloc] initWithInsertTimes:values
                                                        duration:_editor.composition.duration];
}

- (void)pickVideoInsertAtIndex:(NSUInteger)index {
    __weak typeof(self) ws = self;
    [HTAssetPickerController pickVideo:^(AVAsset * _Nullable asset) {
        if (!asset) return;
        [ws.editor insertVideoAsset:asset atIndex:index];
        ws.insertTimeHelper = [ws createInsertTimeHelper];
        
        AVPlayerItem *playerItem = [ws.editor createPlayItem];
        CMTime seekTime = [ws.editor insertTimeOfVideoAssetAtIndex:index];
        [playerItem seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [ws.player replaceCurrentItemWithPlayerItem:playerItem];
        [ws.progressBar insertAsset:asset atIndex:index];
    }];
}

- (void)cleanDisk {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *foldPath = [self foldPath];
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:foldPath isDirectory:&isDirectory] && isDirectory) {
        [fileManager removeItemAtPath:foldPath error:nil];
        [fileManager createDirectoryAtPath:foldPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (void)showAlert:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:okAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveVideoToAlbum:(NSURL *)url {
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:url];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showAlert:success ? @"已保存相册" : @"保存相册失败"];
        });
    }];
}

#pragma mark - Getter
- (UIView *)navBar {
    if (!_navBar) {
        _navBar = [[UIView alloc] init];
        _navBar.backgroundColor = [UIColor ht_primaryColor];
        
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [backBtn setImage:[UIImage imageNamed:@"edit_nav_back"] forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        [_navBar addSubview:backBtn];
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(40, 40));
            make.leading.equalTo(_navBar).offset(0);
            make.centerY.equalTo(_navBar);
        }];
        
        UIButton *exportBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [exportBtn setTitle:@"导出" forState:UIControlStateNormal];
        exportBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [exportBtn addTarget:self action:@selector(exportBtnAction) forControlEvents:UIControlEventTouchUpInside];
        [_navBar addSubview:exportBtn];
        [exportBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 40));
            make.trailing.equalTo(_navBar).offset(-10);
            make.centerY.equalTo(backBtn);
        }];
        
        UIView *line = [UIView new];
        line.backgroundColor = [UIColor ht_lineColor];
        [_navBar addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.leading.trailing.equalTo(_navBar);
            make.height.equalTo(@0.5);
        }];
    }
    return _navBar;
}

- (HTVideoEditProgressBar *)progressBar {
    if (!_progressBar) {
        _progressBar = [[HTVideoEditProgressBar alloc] initWithAssets:[self assets]];
        _progressBar.delegate = self;
        _progressBar.playButton.enabled = NO;
        [_progressBar.playButton addTarget:self action:@selector(playButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _progressBar;
}

- (NSArray<AVAsset *> *)assets {
    NSMutableArray *array = @[].mutableCopy;
    for (HTAssetSegment *segment in _editor.assetSegments) {
        [array addObject:segment.asset];
    }
    return array;
}

#pragma mark - Setter
- (void)setCurrentEditSection:(NSInteger)currentEditSection {
    _currentEditSection = currentEditSection;
    _toolView.enableRemoveVideo = currentEditSection >= 0 && _editor.assetSegments.count > 1;
}

#pragma mark - Action
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (context == playerItemStatusObserveContext) {
        if (![change[NSKeyValueChangeNewKey] isKindOfClass:NSNumber.class]) {
            return;
        }
        AVPlayerStatus status = [change[NSKeyValueChangeNewKey] integerValue];
        _progressBar.playButton.enabled = status == AVPlayerItemStatusReadyToPlay;
    } else if (context == playerRateObserveContext) {
        float rate = [change[NSKeyValueChangeNewKey] floatValue];
        _progressBar.playButton.selected = rate > 0;
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)playButtonAction:(UIButton *)sender {
    if (sender.selected) {
        [_player pause];
    } else {
        if (CMTimeCompare(_player.currentTime, _player.currentItem.asset.duration) == 0) {
            [_player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        }
        [_player play];
    }
}

- (void)exportBtnAction {
    __weak typeof(self) ws = self;
    HTExportProgressView *progressView = [HTExportProgressView exportProgressViewWithCloseAction:^{
        [ws.editor cancelExport];
    }];
    [progressView show];
    NSURL *url = [self exportVideoURL];
    CALayer *stickerLayer = [_playerView createStickerContainerLayerForVideoExport];
    [_editor exportToURL:url withPresetName:AVAssetExportPresetHighestQuality animationLayer:stickerLayer progress:^(float progress) {
        progressView.progress = progress;
    } complete:^(BOOL success, NSError * _Nullable error) {
        NSLog(@"%@: %d, %@", url, success, error.localizedDescription);
        [progressView dismiss];
        if (success) {
            [ws saveVideoToAlbum:url];
        } else {
            [ws showAlert:@"导出失败"];
        }
    }];
}

- (void)playerTimeUpdate:(CMTime)time {
    Float64 duration = CMTimeGetSeconds(_player.currentItem.asset.duration);
    Float64 sec = CMTimeGetSeconds(time);
    float progress = sec/duration;
    BOOL dragingTimeRangeView = self.progressBar.dragingTimeRangeView;
    if (!dragingTimeRangeView) {
        self.progressBar.progress = progress;
        if (_playerView.currentSelectedSticker &&
            !CMTimeRangeContainsTime(_playerView.currentSelectedSticker.timeRange, time)) {
            [_playerView cancelSelectSticker];
            [self.progressBar selectStickerWithTimeRange:kCMTimeRangeInvalid];
            [_toolView selectSticker:nil];
        }
    }
    HTInsertTime *obj = [_insertTimeHelper insertTimeObjectMatchProgress:progress];
    _toolView.enableInsertVideo = obj != nil;
    _toolView.enableAddSticker = CMTimeCompare(CMTimeSubtract(_player.currentItem.asset.duration, time), kMinDuration) >= 0;
}

#pragma mark - HTVideoEditToolViewDelegate
- (void)videoEditToolViewDidClickInsertVideo:(HTVideoEditToolView *)toolView {
    NSInteger index = [self.insertTimeHelper indexOfInsertTimeObjectMatchProgress:self.progressBar.progress];
    if (index < 0) return;
    [self pickVideoInsertAtIndex:index];
}
- (void)videoEditToolViewDidClickRemoveVideo:(HTVideoEditToolView *)toolView {
    [self.editor removeVideoAssetAtIndex:self.currentEditSection];
    self.insertTimeHelper = [self createInsertTimeHelper];
    
    AVPlayerItem *playerItem = [self.editor createPlayItem];
    [self.player replaceCurrentItemWithPlayerItem:playerItem];
    [self.progressBar removeAssetAtIndex:self.currentEditSection];
    [_playerView adjustStickersTimeRangeWithMinDuration:kMinDuration];
}
- (void)videoEditToolViewDidClickAddText:(HTVideoEditToolView *)toolView {
    HTTextStickerView *textSticker = [[HTTextStickerView alloc] initWithText:@"写点什么abc"];
    CMTime defaultDuration = CMTimeMake(3*30, 30);
    CMTime maxDuration = CMTimeSubtract(self.player.currentItem.asset.duration, self.player.currentTime);
    textSticker.timeRange = CMTimeRangeMake(self.player.currentTime, CMTimeMinimum(defaultDuration, maxDuration));
    [_playerView addSticker:textSticker];
    [_playerView selectSticker:textSticker];
    [self.progressBar selectStickerWithTimeRange:textSticker.timeRange];
    [toolView selectSticker:textSticker];
}
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectImage:(NSURL *)url {
    if (_playerView.currentSelectedSticker) {
        HTImageStickerView *imageSticker = (HTImageStickerView *)_playerView.currentSelectedSticker;
        imageSticker.URL = url;
    } else {
        HTImageStickerView *imageSticker = [[HTImageStickerView alloc] initWithImageURL:url];
        CMTime defaultDuration = CMTimeMake(3*30, 30);
        CMTime maxDuration = CMTimeSubtract(self.player.currentItem.asset.duration, self.player.currentTime);
        imageSticker.timeRange = CMTimeRangeMake(self.player.currentTime, CMTimeMinimum(defaultDuration, maxDuration));
        [_playerView addSticker:imageSticker];
        [_playerView selectSticker:imageSticker];
        [self.progressBar selectStickerWithTimeRange:imageSticker.timeRange];
        [toolView selectSticker:imageSticker];
    }
}
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectColor:(UIColor *)color {
    HTTextStickerView *textSticker = (HTTextStickerView *)_playerView.currentSelectedSticker;
    textSticker.textColor = color;
}
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didSelectFont:(NSString *)fontName {
    HTTextStickerView *textSticker = (HTTextStickerView *)_playerView.currentSelectedSticker;
    textSticker.fontName = fontName;
}
- (void)videoEditToolView:(HTVideoEditToolView *)toolView didCancelSelectSticker:(HTStickerView *)sticker {
    [self.progressBar selectStickerWithTimeRange:kCMTimeRangeInvalid];
    [_playerView cancelSelectSticker];
}

#pragma mark - HTVideoEditProgressBarDelegate
- (void)progressBar:(HTVideoEditProgressBar *)progressBar dragToProgress:(double)progress {
    if (_player.rate > 0) {
        [_player pause];
    } else {
        CMTime time = CMTimeMultiplyByFloat64(_player.currentItem.asset.duration, progress);
        [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}
- (void)progressBar:(HTVideoEditProgressBar *)progressBar didEndDragToProgress:(double)progress {
    HTInsertTime *insertTimeObj = [_insertTimeHelper insertTimeObjectMatchProgress:progress];
    CMTime time = kCMTimeZero;
    if (insertTimeObj) {
        time = insertTimeObj.time;
    } else {
        time = CMTimeMultiplyByFloat64(_player.currentItem.asset.duration, progress);
    }
    [_player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
- (void)progressBar:(HTVideoEditProgressBar *)progressBar beginDragTimeRangePosition:(KKTimeRangeViewTouchPosition)position {
    if (self.currentEditSection >= 0) {
        HTAssetSegment *segment = _editor.assetSegments[self.currentEditSection];
        self.editSectionTimeRange = segment.assetTimeRange;

        AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:segment.asset];
        CMTime time = kCMTimeZero;
        if (position == KKTimeRangeViewTouchPositionLeft) {
            time = segment.assetTimeRange.start;
        } else {
            time = CMTimeRangeGetEnd(segment.assetTimeRange);
        }
        [playerItem seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [_player replaceCurrentItemWithPlayerItem:playerItem];
    }
}
- (void)progressBar:(HTVideoEditProgressBar *)progressBar endDragTimeRangePosition:(KKTimeRangeViewTouchPosition)position {
    if (self.currentEditSection >= 0) {
        [_editor updateAssetTimeRange:_editSectionTimeRange ofVideoAssetAtIndex:_currentEditSection];
        _insertTimeHelper = [self createInsertTimeHelper];
        
        CMTime seekTime = [_editor insertTimeOfVideoAssetAtIndex:_currentEditSection];
        if (position == KKTimeRangeViewTouchPositionRight) {
            seekTime = CMTimeAdd(seekTime, _editSectionTimeRange.duration);
        }
        AVPlayerItem *playItem = [self.editor createPlayItem];
        [playItem seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
        [_player replaceCurrentItemWithPlayerItem:playItem];
        [_playerView adjustStickersTimeRangeWithMinDuration:kMinDuration];
    } else {
        
    }
}

- (void)progressBar:(HTVideoEditProgressBar *)progressBar dragTimeRangeDuration:(CMTime)duration position:(KKTimeRangeViewTouchPosition)position isReachEdge:(BOOL)isReachEdge {
    if (self.currentEditSection >= 0) {
        HTAssetSegment *segment = _editor.assetSegments[self.currentEditSection];
        CMTime maxDuration = kCMTimeZero;
        if (position == KKTimeRangeViewTouchPositionLeft) {
            maxDuration = CMTimeAdd(segment.assetTimeRange.start, segment.assetTimeRange.duration);
        } else if (position == KKTimeRangeViewTouchPositionRight){
            maxDuration = CMTimeSubtract(segment.maxDuration, segment.assetTimeRange.start);
        }
        if (CMTimeCompare(duration, maxDuration) > 0) {
            duration = maxDuration;
        } else if (CMTimeCompare(duration, kMinDuration) < 0) {
            duration = kMinDuration;
        }
        CMTime seekTime = kCMTimeZero;
        if (position == KKTimeRangeViewTouchPositionLeft) {
            CMTime newStart = CMTimeAdd(segment.assetTimeRange.start, CMTimeSubtract(segment.assetTimeRange.duration, duration));
            [progressBar changeStartTime:newStart ofAssetAtSection:self.currentEditSection needUpdateContentOffset:isReachEdge];
            self.editSectionTimeRange = CMTimeRangeMake(newStart, duration);
            seekTime = newStart;
        } else if (position == KKTimeRangeViewTouchPositionRight){
            CMTime newEnd = CMTimeAdd(segment.assetTimeRange.start, duration);
            [progressBar changeEndTime:newEnd ofAssetAtSection:self.currentEditSection needUpdateContentOffset:isReachEdge];
            self.editSectionTimeRange = CMTimeRangeMake(segment.assetTimeRange.start, duration);
            seekTime = newEnd;
        }
        [_player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    } else {
        CMTime maxDuration = kCMTimeZero;
        if (position == KKTimeRangeViewTouchPositionLeft) {
            maxDuration = CMTimeRangeGetEnd(_playerView.currentSelectedSticker.timeRange);
        } else if (position == KKTimeRangeViewTouchPositionRight){
            maxDuration = CMTimeSubtract(_player.currentItem.asset.duration, _playerView.currentSelectedSticker.timeRange.start);
        }
        if (CMTimeCompare(duration, maxDuration) > 0) {
            duration = maxDuration;
        } else if (CMTimeCompare(duration, kMinDuration) < 0) {
            duration = kMinDuration;
        }
        CMTime seekTime = kCMTimeZero;
        if (position == KKTimeRangeViewTouchPositionLeft) {
            CMTime newStart = CMTimeAdd(_playerView.currentSelectedSticker.timeRange.start, CMTimeSubtract(_playerView.currentSelectedSticker.timeRange.duration, duration));
            [self.progressBar changeStickerStartTime:newStart needUpdateContentOffset:isReachEdge];
            _playerView.currentSelectedSticker.timeRange = CMTimeRangeMake(newStart, duration);
            seekTime = newStart;
        } else if (position == KKTimeRangeViewTouchPositionRight){
            CMTime newEnd = CMTimeAdd(_playerView.currentSelectedSticker.timeRange.start, duration);
            [self.progressBar changeStickerEndTime:newEnd needUpdateContentOffset:isReachEdge];
            _playerView.currentSelectedSticker.timeRange = CMTimeRangeMake(_playerView.currentSelectedSticker.timeRange.start, duration);
            seekTime = newEnd;
        }
        [_player seekToTime:seekTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
}
- (void)progressBar:(HTVideoEditProgressBar *)progressBar didClickInsertButtonWithType:(HTVideoEditProgressBarInsertSectionType)type {
    NSUInteger index = type == HTVideoEditProgressBarInsertSectionTypeHead ? 0 : _editor.assetSegments.count;
    [self pickVideoInsertAtIndex:index];
}
- (BOOL)progressBar:(HTVideoEditProgressBar *)progressBar shouldSelectSection:(NSUInteger)section {
    return self.playerView.currentSelectedSticker == nil;
}
- (void)progressBar:(HTVideoEditProgressBar *)progressBar didSelectSection:(NSUInteger)section {
    [self.player pause];
    HTAssetSegment *segment = self.editor.assetSegments[section];
    CMTime start = [_editor insertTimeOfVideoAssetAtIndex:section];
    CMTime end = CMTimeAdd(start, segment.assetTimeRange.duration);
    CMTime currentTime = self.player.currentTime;
    if (CMTimeCompare(currentTime, start) < 0 || CMTimeCompare(end, currentTime) < 0) {
        [_player seekToTime:start toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    }
    self.currentEditSection = section;
}
- (void)progressBarDidUnselectSection:(HTVideoEditProgressBar *)progressBar {
    self.currentEditSection = -1;
}

#pragma mark - HTEditPlayerViewDelegate
- (void)editPlayerView:(HTEditPlayerView *)playerView didSelectSticker:(HTStickerView *)sticker {
    [self.progressBar selectStickerWithTimeRange:sticker ? sticker.timeRange : kCMTimeRangeInvalid];
    [self.toolView selectSticker:sticker];
}

#pragma mark - SavePath
- (NSString *)foldPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"VideoEdit"];
}
- (void)createDirectoryIfDontExist:(NSString *)path {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    if (![fileManager fileExistsAtPath:path isDirectory:&isDirectory] || !isDirectory) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

- (NSURL *)exportVideoURL {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *outputDirectoryPath = [self foldPath];
    [self createDirectoryIfDontExist:outputDirectoryPath];
    NSString *outputFilePath = [outputDirectoryPath stringByAppendingPathComponent:@"export.mp4"];
    if ([fileManager fileExistsAtPath:outputFilePath]) {
        [fileManager removeItemAtPath:outputFilePath error:nil];
    }
    return [NSURL fileURLWithPath:outputFilePath];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
