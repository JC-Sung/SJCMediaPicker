//
//  SJCPhotoConfiguration.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/16.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCPhotoConfiguration.h"

@implementation SJCPhotoConfiguration

+ (instancetype)defaultPhotoConfiguration {
    SJCPhotoConfiguration *configuration = [SJCPhotoConfiguration new];
    configuration.maxSelectCount = 9;
    configuration.sortAscending = NO;
    configuration.navTintColor = [UIColor blackColor];
    configuration.columnNumber = 4;
    configuration.columnMargin = 1;
    configuration.allowMixSelect = NO;
    configuration.allowSelectImage = YES;
    configuration.allowSelectVideo = YES;
    configuration.allowSelectGif = YES;
    configuration.showEachAlbumSecletedCount = YES;
    configuration.showSecletIndex = YES;
    configuration.allowCrop = YES;
    configuration.allowMultiCrop = YES;
    configuration.cropScale = 1.0/1.0;
    configuration.allowMultiScale = YES;
    configuration.needFilter = YES;
    
    return configuration;
}

@end

