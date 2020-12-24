//
//  SJCCropWHScaleView.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/30.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@protocol SJCCropWHScaleViewDelegate <NSObject>
@optional
- (void)didSecletWHScale:(CGFloat)WHScale;
@end

@interface SJCCropWHScaleView : UIView
@property(weak,nonatomic) id <SJCCropWHScaleViewDelegate>delegate;
@property(assign,nonatomic) CGFloat currentScale;
@end

NS_ASSUME_NONNULL_END
