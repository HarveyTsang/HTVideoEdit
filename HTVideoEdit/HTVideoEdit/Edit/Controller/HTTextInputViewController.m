//
//  HTTextInputViewController.m
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import "HTTextInputViewController.h"
#import "UIApplication+Extension.h"

@interface HTTextInputViewController ()<UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning, UITextViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIButton *finishButton;

@end

@implementation HTTextInputViewController

- (instancetype)init {
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    [self setupSubviews];
    [self.textView becomeFirstResponder];
    
    
}
- (void)viewDidAppear:(BOOL)animated {
    UITextPosition *start = self.textView.beginningOfDocument;
    UITextPosition *end = [self.textView positionFromPosition:start offset:self.textView.text.length];
    self.textView.selectedTextRange = [self.textView textRangeFromPosition:start toPosition:end];
}

- (void)setupSubviews {
    self.containerView = [UIView new];
    self.containerView.backgroundColor = [UIColor ht_colorWithHexString:@"C3C3C3"];
    self.containerView.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, 48.0);
    [self.view addSubview:self.containerView];
    
    [self.containerView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(8, 8, 8, 66));
    }];
    
    [self.containerView addSubview:self.finishButton];
    [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.containerView).offset(8);
        make.trailing.equalTo(self.containerView).offset(-8);
        make.bottom.equalTo(self.containerView).offset(-8);
        make.leading.equalTo(self.textView.mas_trailing).offset(8);
    }];
}

- (UITextView *)textView {
    if (!_textView) {
        _textView = [[UITextView alloc] init];
        _textView.font = [UIFont systemFontOfSize:15];
        _textView.inputAccessoryView = [[UIView alloc] init];
        _textView.delegate = self;
        _textView.enablesReturnKeyAutomatically = YES;
    }
    return _textView;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"确认" forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor ht_primaryColor] forState:UIControlStateNormal];
        [_finishButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_finishButton addTarget:self action:@selector(finishButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _finishButton;
}

- (void)setText:(NSString *)text {
    self.textView.text = text;
}

- (void)show {
    UIViewController *topVC = [UIApplication.sharedApplication ht_topViewController];
    [topVC presentViewController:self animated:YES completion:nil];
}

#pragma mark - Action
- (void)keyboardShow:(NSNotification *)notif {
    if (!self.textView.isFirstResponder) return;
    
    NSDictionary *userInfo = notif.userInfo;
    CGRect keyboardFrame = [[userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect frame = self.containerView.frame;
    frame.origin.y = keyboardFrame.origin.y - frame.size.height;
    self.containerView.frame = frame;
}
- (void)finishButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(textInputViewController:changeText:)]) {
        [self.delegate textInputViewController:self changeText:self.textView.text];
    }
    if (self.textChange) {
        self.textChange(self.textView.text);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    self.finishButton.enabled = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return self;
}
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext{
    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    if (!toVC || !fromVC || !containerView) return;
    
    UIView *fromView = fromVC.view;
    UIView *toView = toVC.view;
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    if (toVC == self){
        [containerView addSubview:toView];
        self.containerView.transform = CGAffineTransformMakeScale(1.6, 1.6);
        toView.alpha = 0;
        fromView.tintAdjustmentMode = UIViewTintAdjustmentModeDimmed;
        
        [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            toView.alpha = 1;
            self.containerView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            BOOL isCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!isCancelled];
        }];
    }
    
    if (fromVC == self){
        [UIView animateWithDuration:duration animations:^{
            self.containerView.transform = CGAffineTransformMakeScale(0.5, 0.5);
            fromView.alpha = 0;
        } completion:^(BOOL finished) {
            toView.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
            BOOL isCancelled = [transitionContext transitionWasCancelled];
            [transitionContext completeTransition:!isCancelled];
        }];
    }
}
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext{
    return 0.01;
}

@end
