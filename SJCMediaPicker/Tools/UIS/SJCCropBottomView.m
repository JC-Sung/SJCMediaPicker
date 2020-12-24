//
//  SJCCropBottomView.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/29.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCCropBottomView.h"
#import "SJCMacro.h"

#define btnWith 24
#define btnMargin (self.sjc_width - 40*2 - btnWith*6)/7.0

@implementation SJCCropBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    
    _cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancleBtn setTitle:SJCLocalized(@"Cancle") forState:UIControlStateNormal];
    _cancleBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_cancleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancleBtn addTarget:self action:@selector(cancleBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_cancleBtn];
    
    _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_doneBtn setTitle:SJCLocalized(@"Complete") forState:UIControlStateNormal];
    _doneBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_doneBtn addTarget:self action:@selector(doneBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_doneBtn];
    
    _horMirrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_horMirrorBtn setImage:GetImageBundle(@"sic_jingxiangH.png") forState:UIControlStateNormal];
    [_horMirrorBtn addTarget:self action:@selector(horMirrorBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_horMirrorBtn];
    
    _verMirrorBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_verMirrorBtn setImage:GetImageBundle(@"sic_jingxiangV.png") forState:UIControlStateNormal];
    [_verMirrorBtn addTarget:self action:@selector(verMirrorBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_verMirrorBtn];
    
    _rotateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rotateBtn setImage:GetImageBundle(@"sic_xuanzhuan.png") forState:UIControlStateNormal];
    [_rotateBtn addTarget:self action:@selector(rotateBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_rotateBtn];
    
    _previewBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previewBtn setImage:GetImageBundle(@"sic_yulan.png") forState:UIControlStateNormal];
    [_previewBtn addTarget:self action:@selector(previewBtnAction:forEvent:) forControlEvents:UIControlEventAllTouchEvents];
    [self addSubview:_previewBtn];
    
    _lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lockBtn setImage:GetImageBundle(@"sic_suodingon.png") forState:UIControlStateNormal];
    [_lockBtn setImage:GetImageBundle(@"sic_suodingoff.png") forState:UIControlStateSelected];
    [_lockBtn addTarget:self action:@selector(lockBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_lockBtn];
    
    _resizeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resizeBtn setImage:GetImageBundle(@"sic_zhongzhi.png") forState:UIControlStateNormal];
    [_resizeBtn addTarget:self action:@selector(resizeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resizeBtn];
    
    _resizeBtnS = [UIButton buttonWithType:UIButtonTypeCustom];
    [_resizeBtnS setTitle:SJCLocalized(@"还原") forState:UIControlStateNormal];
    _resizeBtnS.titleLabel.font = [UIFont systemFontOfSize:16];
    [_resizeBtnS setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_resizeBtnS addTarget:self action:@selector(resizeBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resizeBtnS];
}

- (void)setNeedMultiCrop:(BOOL)needMultiCrop {
    _needMultiCrop = needMultiCrop;
    
    _horMirrorBtn.hidden = !needMultiCrop;
    _verMirrorBtn.hidden = !needMultiCrop;
    _rotateBtn.hidden = !needMultiCrop;
    _previewBtn.hidden = !needMultiCrop;
    _lockBtn.hidden = !needMultiCrop;
    _resizeBtn.hidden = !needMultiCrop;
    _resizeBtnS.hidden = needMultiCrop;
}

- (void)cancleBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancleBtnClick:)]) {
        [self.delegate cancleBtnClick:sender];
    }
}

- (void)horMirrorBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(horMirrorBtnClick:)]) {
        [self.delegate horMirrorBtnClick:sender];
    }
}

- (void)verMirrorBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(verMirrorBtnClick:)]) {
        [self.delegate verMirrorBtnClick:sender];
    }
}

- (void)rotateBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rotateBtnClick:)]) {
        [self.delegate rotateBtnClick:sender];
    }
}

- (void)previewBtnAction:(UIButton *)sender forEvent:(UIEvent *)event {
    if (self.delegate && [self.delegate respondsToSelector:@selector(previewBtnClick:forEvent:)]) {
        [self.delegate previewBtnClick:sender forEvent:event];
    }
}

- (void)lockBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(lockBtnClick:)]) {
        [self.delegate lockBtnClick:sender];
    }
}

- (void)resizeBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(resizeBtnClick:)]) {
        [self.delegate resizeBtnClick:sender];
    }
}

- (void)doneBtnAction:(UIButton *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(doneBtnClick:)]) {
        [self.delegate doneBtnClick:sender];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _cancleBtn.frame = CGRectMake(0, 0, [_cancleBtn.titleLabel sjc_textWith], self.sjc_height);
    _doneBtn.frame = CGRectMake(self.sjc_width-[_doneBtn.titleLabel sjc_textWith], 0, [_doneBtn.titleLabel sjc_textWith], self.sjc_height);
    _horMirrorBtn.frame = CGRectMake(_cancleBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _verMirrorBtn.frame = CGRectMake(_horMirrorBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _rotateBtn.frame = CGRectMake(_verMirrorBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _previewBtn.frame = CGRectMake(_rotateBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _lockBtn.frame = CGRectMake(_previewBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _resizeBtn.frame = CGRectMake(_lockBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
    _resizeBtnS.frame = CGRectMake((self.sjc_width-[_resizeBtnS.titleLabel sjc_textWith])*0.5, 0, [_resizeBtnS.titleLabel sjc_textWith], self.sjc_height);
    _horMirrorBtn.frame = CGRectMake(_cancleBtn.sjc_right+btnMargin, (self.sjc_height-btnWith)*0.5, btnWith, btnWith);
}
@end

