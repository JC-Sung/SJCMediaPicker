//
//  SJCAnimationTranstion.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SJCTransitionType) {
    SJCTransitionTypeNone,
    SJCTransitionTypePush,
    SJCTransitionTypePop,
};


@interface SJCAnimationTranstion : NSObject<UIViewControllerAnimatedTransitioning>

+ (instancetype)sjcAnimationTranstionWithType:(SJCTransitionType)type;

@end

