//
//  SJCCropBottomView.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/29.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SJCCropBottomDelgate <NSObject>
@optional
- (void)cancleBtnClick:(UIButton *)sender;
- (void)horMirrorBtnClick:(UIButton *)sender;
- (void)verMirrorBtnClick:(UIButton *)sender;
- (void)rotateBtnClick:(UIButton *)sender;
- (void)previewBtnClick:(UIButton *)sender forEvent:(UIEvent *)event;
- (void)lockBtnClick:(UIButton *)sender;
- (void)resizeBtnClick:(UIButton *)sender;
- (void)doneBtnClick:(UIButton *)sender;
@end

@interface SJCCropBottomView : UIView

@property(assign,nonatomic) BOOL needMultiCrop;

//取消按钮
@property (nonatomic, strong) UIButton *cancleBtn;
//水平镜像按钮
@property (nonatomic, strong) UIButton *horMirrorBtn;
//垂直镜像按钮
@property (nonatomic, strong) UIButton *verMirrorBtn;
//旋转按钮
@property (nonatomic, strong) UIButton *rotateBtn;
//预览按钮
@property (nonatomic, strong) UIButton *previewBtn;
//锁定按钮
@property (nonatomic, strong) UIButton *lockBtn;
//重置按钮
@property (nonatomic, strong) UIButton *resizeBtn;
//重置按钮
@property (nonatomic, strong) UIButton *resizeBtnS;
//完成按钮
@property (nonatomic, strong) UIButton *doneBtn;

@property (nonatomic, weak) id<SJCCropBottomDelgate> delegate;
@end

NS_ASSUME_NONNULL_END
