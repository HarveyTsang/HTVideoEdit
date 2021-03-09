//
//  HTTextInputViewController.h
//  HTVideoEdit
//
//  Created by HarveyTsang on 2021/2/21.
//  Copyright (c) HarveyTsang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HTTextInputViewController;
@protocol HTTextInputViewControllerDelegate <NSObject>
@optional
- (void)textInputViewController:(HTTextInputViewController *)vc changeText:(NSString *)text;

@end

typedef void(^HTTextInputVCTextChange)(NSString *text);

@interface HTTextInputViewController : UIViewController

@property (nonatomic, weak, nullable) id<HTTextInputViewControllerDelegate> delegate;

@property (nonatomic, copy, nullable) HTTextInputVCTextChange textChange;

- (void)setText:(NSString *)text;

- (void)show;

@end

NS_ASSUME_NONNULL_END
