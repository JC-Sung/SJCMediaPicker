//
//  SJCAlbumModel.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCPhotoModel.h"

@implementation SJCPhotoModel

+ (instancetype)modelWithAsset:(PHAsset *)asset type:(SJCAssetMediaType)type duration:(NSString *)duration{
    SJCPhotoModel *model = [[SJCPhotoModel alloc] init];
    model.asset = asset;
    model.type = type;
    model.duration = duration;
    model.selected = NO;
    model.secletIndex = 0;
    return model;
}

@end

@implementation SJCAlbumModel

@end
