//
//  SJCMediaCropController.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaCropController.h"
#import "SJCMacro.h"
#import "JPImageresizerView.h"
#import "SJCCropBottomView.h"
#import "SJCCropWHScaleView.h"
#import "SJCMediaFilterController.h"

@interface SJCMediaCropController ()<SJCCropBottomDelgate, SJCCropWHScaleViewDelegate>
@property (nonatomic, weak) JPImageresizerView *imageresizerView;
@property (nonatomic, strong) SJCCropBottomView *bottomView;
@property (nonatomic, strong) SJCCropWHScaleView *scaleView;
@end

@implementation SJCMediaCropController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self createAllViews];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)createAllViews{
    //这种获取的相册图是高清的，但是现实模糊什么问题，换了种获取相册原图的方法
    //    @sjc_weakify(self);
    //    [SJCPhotoManager requestOriginalImageForAsset:self.model.asset progressHandler:nil completion:^(UIImage * _Nonnull image, NSDictionary * _Nonnull info) {
    //        @sjc_strongify(self);
    //      [self initimageresizerView:image];
    //    }];
        
        //PHImageManagerMaximumSize为什么不行，但前一种方法可以
        @sjc_weakify(self);
        [SJCPhotoManager requestLargePhotoForAsset:self.model.asset targetSize:CGSizeMake(self.model.asset.pixelWidth, self.model.asset.pixelHeight) isFastMode:NO isShouldFixOrientation:NO resultHandler:^(PHAsset *requestAsset, UIImage *result, NSDictionary *info) {
            @sjc_strongify(self);
            if (!self) return;
            if (result) {
                [self initimageresizerView:result];
            } else {
                SJCLog(@"照片获取失败");
            }
        }];
    
}

- (void)initimageresizerView:(UIImage *)image {
    @sjc_weakify(self);

    self.bottomView.resizeBtn.enabled = NO;
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    
    JPImageresizerConfigure *configure = [JPImageresizerConfigure defaultConfigureWithResizeImage:image make:^(JPImageresizerConfigure *kConfigure) {
        kConfigure.jp_contentInsets(UIEdgeInsetsMake(SJCStatusBarAndNavigationBarHeight, 10, SJCTabbarSafeBottomMargin+60+(nav.configuration.allowMultiScale?60:0), 10))
        .jp_maskAlpha(0.35)
        .jp_resizeWHScale(0.0)
        .jp_maskType(JPDarkBlurMaskType)
        .jp_frameType(JPClassicFrameType)
        .jp_viewFrame(CGRectMake(0, 0, SJC_WIDTH, SJC_HEIGHT-0));
        }];
    JPImageresizerView *imageresizerView = [JPImageresizerView imageresizerViewWithConfigure:configure imageresizerIsCanRecovery:^(BOOL isCanRecovery) {
        @sjc_strongify(self);
        if (!self) return;
        // 当不需要重置设置按钮不可点
        self.bottomView.resizeBtn.enabled = isCanRecovery;
        self.bottomView.resizeBtnS.enabled = isCanRecovery;
    } imageresizerIsPrepareToScale:^(BOOL isPrepareToScale) {
        @sjc_strongify(self);
        if (!self) return;
        // 当预备缩放设置按钮不可点，结束后可点击
        BOOL enabled = !isPrepareToScale;
        self.bottomView.rotateBtn.enabled = enabled;
        self.bottomView.horMirrorBtn.enabled = enabled;
        self.bottomView.verMirrorBtn.enabled = enabled;
    }];
    [self.view insertSubview:imageresizerView atIndex:0];
    _imageresizerView = imageresizerView;
    
    self.bottomView.needMultiCrop = nav.configuration.allowMultiCrop;
    [self.view addSubview:self.bottomView];
    
    self.scaleView.hidden = !nav.configuration.allowMultiCrop||!nav.configuration.allowMultiScale;
    self.scaleView.currentScale = nav.configuration.cropScale;
    [self.view addSubview:self.scaleView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    [self.imageresizerView setResizeWHScale:nav.configuration.cropScale isToBeArbitrarily:NO animated:YES];
}

#pragma mark - SJCCropBottomDelgate
- (void)cancleBtnClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)horMirrorBtnClick:(UIButton *)sender {
    self.imageresizerView.horizontalMirror = !self.imageresizerView.horizontalMirror;
}

- (void)verMirrorBtnClick:(UIButton *)sender {
    self.imageresizerView.verticalityMirror = !self.imageresizerView.verticalityMirror;
}

- (void)rotateBtnClick:(UIButton *)sender {
    [self.imageresizerView rotation];
}

- (void)previewBtnClick:(UIButton *)sender forEvent:(UIEvent *)event {
    UITouchPhase phase = event.allTouches.anyObject.phase;
    if (phase == UITouchPhaseBegan) {
        self.imageresizerView.isPreview = YES;
    }
    else if(phase == UITouchPhaseEnded){
        self.imageresizerView.isPreview = NO;
    }
}

- (void)lockBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
    self.imageresizerView.isLockResizeFrame = sender.selected;
}

- (void)resizeBtnClick:(UIButton *)sender {
    [self.imageresizerView recoveryByCurrentResizeWHScale];
}

#pragma mark - SJCCropWHScaleViewDelegate
- (void)didSecletWHScale:(CGFloat)WHScale {
    [self.imageresizerView setResizeWHScale:WHScale isToBeArbitrarily:NO animated:YES];
    if (WHScale==0) {
        [self.imageresizerView recoveryByCurrentResizeWHScale];
    }
}

- (void)doneBtnClick:(UIButton *)sender {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    
    @sjc_weakify(self);
    [self.imageresizerView originImageresizerWithComplete:^(UIImage *resizeImage) {
        @sjc_strongify(self);
        if (nav.configuration.needFilter) {
            [self filterAction:resizeImage];
        }else {
            [self doneAction:resizeImage];
        }
    }];
}

- (void)filterAction:(UIImage *)result {
    SJCMediaFilterController *vc = [SJCMediaFilterController new];
    vc.orginImage = result;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)doneAction:(UIImage *)result {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    if (nav.cropDoneHandel) {
        nav.cropDoneHandel(result);
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (SJCCropBottomView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[SJCCropBottomView alloc] initWithFrame:CGRectMake(10, SJC_HEIGHT-60-SJCTabbarSafeBottomMargin, self.view.sjc_width-10*2, 60)];
        _bottomView.delegate = self;
    }
    return _bottomView;
}

- (SJCCropWHScaleView *)scaleView {
    if (!_scaleView) {
        _scaleView = [[SJCCropWHScaleView alloc] initWithFrame:CGRectMake(10, SJC_HEIGHT-60-SJCTabbarSafeBottomMargin-60, self.view.sjc_width-10*2, 60)];
        _scaleView.delegate = self;
    }
    return _scaleView;
}

- (void)dealloc {
    
}
@end



