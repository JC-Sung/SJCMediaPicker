//
//  SJCInteractiveTrasition.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SJCInteractiveTrasition : UIPercentDrivenInteractiveTransition
@property(assign,nonatomic) BOOL isInteractive;
@property (nonatomic, assign) BOOL shouldComplete;
@property (nonatomic, strong) UIViewController *presentingVC;
@end

NS_ASSUME_NONNULL_END
