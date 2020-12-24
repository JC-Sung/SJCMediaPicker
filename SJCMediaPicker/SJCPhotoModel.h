//
//  SJCAlbumModel.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef NS_ENUM(NSUInteger, SJCAssetMediaType) {
    SJCAssetMediaTypeUnknown,
    SJCAssetMediaTypeImage,
    SJCAssetMediaTypeGif,
    SJCAssetMediaTypeLivePhoto,
    SJCAssetMediaTypeVideo,
    SJCAssetMediaTypeAudio,
    SJCAssetMediaTypeNetImage,
    SJCAssetMediaTypeNetVideo,
};

@interface SJCPhotoModel : NSObject
//asset对象
@property (nonatomic, strong) PHAsset *asset;
//asset类型
@property (nonatomic, assign) SJCAssetMediaType type;
//视频时长
@property (nonatomic, copy) NSString *duration;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;

@property (nonatomic, assign) NSInteger secletIndex;
//网络/本地 图片url
@property (nonatomic, strong) NSURL *url ;
//图片
@property (nonatomic, strong) UIImage *image;
/**初始化model对象*/
+ (instancetype)modelWithAsset:(PHAsset *)asset type:(SJCAssetMediaType)type duration:(NSString *)duration;
@end

@interface SJCAlbumModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger count;
@property (nonatomic, assign) NSInteger secletCount;
@property (nonatomic, assign) BOOL isCameraRoll;
@property (nonatomic, strong) PHFetchResult *result;
//相册第一张图asset对象
@property (nonatomic, strong) PHAsset *headImageAsset;
@property (nonatomic, strong) NSArray<SJCPhotoModel *> *models;
@property (nonatomic, strong) NSArray *selectedModels;
//是否被选择
@property (nonatomic, assign, getter=isSelected) BOOL selected;
@end

