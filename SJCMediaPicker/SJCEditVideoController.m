//
//  SJCEditVideoController.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/31.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCEditVideoController.h"
#import "SJCMacro.h"
#import <AVFoundation/AVFoundation.h>

/**
 *要实现的功能1.对视频进行裁剪
 *2.对视频添加水印或者贴图
 *3.对视频加音乐，控制原声和添加音乐的音量
 *4.视频的循环和倒放
 *5.对视频添加滤镜
 */
@interface SJCEditVideoController ()
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@end

@implementation SJCEditVideoController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    [self setupuis];
    [self analysisAssetImages];
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

- (void)setupuis {
    self.playerLayer = [[AVPlayerLayer alloc] init];
    self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer:self.playerLayer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerLayer.player.currentItem];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIEdgeInsets inset = UIEdgeInsetsZero;
    if (@available(iOS 11, *)) {
        inset = self.view.safeAreaInsets;
    }
    self.playerLayer.frame = CGRectMake(0, inset.top>0?inset.top:30, SJC_WIDTH, SJC_HEIGHT-250-inset.bottom);
}

#pragma mark - 解析视频每一帧图片
- (void)analysisAssetImages{
//    float duration = roundf(self.model.asset.duration);
    @sjc_weakify(self);
    [SJCPhotoManager requestVideoForAsset:self.model.asset completion:^(AVPlayerItem *item, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            @sjc_strongify(self);
            if (!item) return;
            AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
            self.playerLayer.player = player;
            [self.playerLayer.player play];
        });
    }];
    
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.version = PHVideoRequestOptionsVersionOriginal;
    options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
    options.networkAccessAllowed = YES;
    [[PHImageManager defaultManager] requestAVAssetForVideo:self.model.asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        
    }];
}

// 视频循环播放
- (void)moviePlayDidEnd:(NSNotification*)notification{
    
//    AVPlayerItem*item = [notification object];
//    [item seekToTime:kCMTimeZero];
//    [self.playerLayer.player play];
    
    [self.playerLayer.player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [self.playerLayer.player play];
}

@end
