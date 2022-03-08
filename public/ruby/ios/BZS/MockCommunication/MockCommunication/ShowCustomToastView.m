//
//  ShowCustomToastView.m
//  WLPieView
//
//  Created by TChat on 2021/4/28.
//  Copyright © 2021 https://github.com/orzzh. All rights reserved.
//

#import "ShowCustomToastView.h"

@interface ShowCustomToastView ()

@property (strong, nonatomic) UIView *contentView;
@property (nonatomic, assign) NSInteger time;

@end

@implementation ShowCustomToastView

+ (void)showToast:(NSString *)toast time:(CGFloat)time {
    ShowCustomToastView *toastView = [[ShowCustomToastView alloc] init];
    toastView.layer.cornerRadius = 8;
    toastView.layer.masksToBounds = YES;
    toastView.time = time;
    [toastView show];
    // 背景80%#000000
    UIWindow *rootWindow = [[UIApplication sharedApplication].windows lastObject];
    toastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
    toastView.translatesAutoresizingMaskIntoConstraints = false;
    [[toastView.centerXAnchor constraintEqualToAnchor:rootWindow.centerXAnchor constant:0] setActive:true];
    [[toastView.centerYAnchor constraintEqualToAnchor:rootWindow.centerYAnchor constant:0] setActive:true];
    [[toastView.widthAnchor constraintLessThanOrEqualToConstant:280] setActive:true];
    [[toastView.widthAnchor constraintGreaterThanOrEqualToConstant:150] setActive:true];
    [[toastView.heightAnchor constraintEqualToConstant:50] setActive:true];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = toast.length == 0 ? @"未知错误" : toast;
    label.numberOfLines = 2;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    [toastView addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = false;
    [[label.centerYAnchor constraintEqualToAnchor:toastView.centerYAnchor constant:0] setActive:true];
    [[label.leftAnchor constraintEqualToAnchor:toastView.leftAnchor constant:16] setActive:true];
    [[label.rightAnchor constraintEqualToAnchor:toastView.rightAnchor constant:-16] setActive:true];
}

- (void)show {
    UIWindow *rootWindow = [[UIApplication sharedApplication].windows lastObject];
    [[rootWindow viewWithTag:2025] removeFromSuperview];
    self.tag = 2025;
    [rootWindow addSubview:self];
    [self layoutIfNeeded];
    self.alpha = 0;
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
                self.alpha = 0;
            } completion:^(BOOL finished) {
                [self removeFromSuperview];
            }];
        });
    }];
}

@end
