//
//  SJCPhotoManager.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCPhotoManager.h"
#import <UIKit/UIKit.h>
#import "SJCMacro.h"

static BOOL _sortAscending;

@implementation SJCPhotoManager

+ (void)setSortAscending:(BOOL)ascending{
    _sortAscending = ascending;
}

+ (BOOL)sortAscending{
    return _sortAscending;
}

+ (void)getPhotoAblumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^ _Nullable)(NSArray<SJCAlbumModel *> *))complete {
    
    if (!allowSelectImage && !allowSelectVideo) {
        if (complete) complete(nil);
        return;
    }
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    if (!allowSelectVideo) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
    if (!allowSelectImage) option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
    if (!self.sortAscending) option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:self.sortAscending]];
    
    //获取所有智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    PHFetchResult *streamAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumMyPhotoStream options:nil];
    PHFetchResult *userAlbums = [PHCollectionList fetchTopLevelUserCollectionsWithOptions:nil];
    PHFetchResult *syncedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumSyncedAlbum options:nil];
    PHFetchResult *sharedAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumCloudShared options:nil];
    NSArray *arrAllAlbums = @[smartAlbums, streamAlbums, userAlbums, syncedAlbums, sharedAlbums];
    /**
    PHAssetCollectionSubtypeAlbumRegular         = 2,///
    PHAssetCollectionSubtypeAlbumSyncedEvent     = 3,////
    PHAssetCollectionSubtypeAlbumSyncedFaces     = 4,////面孔
    PHAssetCollectionSubtypeAlbumSyncedAlbum     = 5,////
    PHAssetCollectionSubtypeAlbumImported        = 6,////
    
    // PHAssetCollectionTypeAlbum shared subtypes
    PHAssetCollectionSubtypeAlbumMyPhotoStream   = 100,///
    PHAssetCollectionSubtypeAlbumCloudShared     = 101,///
    
    // PHAssetCollectionTypeSmartAlbum subtypes        //// collection.localizedTitle
    PHAssetCollectionSubtypeSmartAlbumGeneric    = 200,///
    PHAssetCollectionSubtypeSmartAlbumPanoramas  = 201,///全景照片
    PHAssetCollectionSubtypeSmartAlbumVideos     = 202,///视频
    PHAssetCollectionSubtypeSmartAlbumFavorites  = 203,///个人收藏
    PHAssetCollectionSubtypeSmartAlbumTimelapses = 204,///延时摄影
    PHAssetCollectionSubtypeSmartAlbumAllHidden  = 205,/// 已隐藏
    PHAssetCollectionSubtypeSmartAlbumRecentlyAdded = 206,///最近添加
    PHAssetCollectionSubtypeSmartAlbumBursts     = 207,///连拍快照
    PHAssetCollectionSubtypeSmartAlbumSlomoVideos = 208,///慢动作
    PHAssetCollectionSubtypeSmartAlbumUserLibrary = 209,///所有照片
    PHAssetCollectionSubtypeSmartAlbumSelfPortraits NS_AVAILABLE_IOS(9_0) = 210,///自拍
    PHAssetCollectionSubtypeSmartAlbumScreenshots NS_AVAILABLE_IOS(9_0) = 211,///屏幕快照
    PHAssetCollectionSubtypeSmartAlbumDepthEffect PHOTOS_AVAILABLE_IOS_TVOS(10_2, 10_1) = 212,///人像
    PHAssetCollectionSubtypeSmartAlbumLivePhotos PHOTOS_AVAILABLE_IOS_TVOS(10_3, 10_2) = 213,//livephotos
    PHAssetCollectionSubtypeSmartAlbumAnimated = 214,///动图
    = 1000000201///最近删除知道值为（1000000201）但没找到对应的TypedefName
    // Used for fetching, if you don't care about the exact subtype
    PHAssetCollectionSubtypeAny = NSIntegerMax /////所有类型
    */
    NSMutableArray<SJCAlbumModel *> *arrAlbum = [NSMutableArray array];
    for (PHFetchResult<PHAssetCollection *> *album in arrAllAlbums) {
        [album enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
            //过滤PHCollectionList对象
            if (![collection isKindOfClass:PHAssetCollection.class]) return;
            //过滤最近删除和已隐藏
            if (collection.assetCollectionSubtype > 215 ||
            collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumAllHidden) return;
            //获取相册内asset result
            PHFetchResult<PHAsset *> *result = [PHAsset fetchAssetsInAssetCollection:collection options:option];
            if (!result.count) return;
            
            if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                //所有照片
                SJCAlbumModel *m = [self getAlbumModeWithTitle:collection.localizedTitle result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage];
                m.isCameraRoll = YES;
                [arrAlbum insertObject:m atIndex:0];
            } else {
                [arrAlbum addObject:[self getAlbumModeWithTitle:collection.localizedTitle result:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage]];
            }
        }];
    }
    if (complete) complete(arrAlbum);
}

//获取相册列表model
+ (SJCAlbumModel *)getAlbumModeWithTitle:(NSString *)title result:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage {
    SJCAlbumModel *model = [[SJCAlbumModel alloc] init];
    model.title = title;
    model.count = result.count;
    model.result = result;
    if (self.sortAscending) {
        model.headImageAsset = result.lastObject;
    } else {
        model.headImageAsset = result.firstObject;
    }
    //为了获取所有asset gif设置为yes
    model.models = [SJCPhotoManager getPhotoInResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectImage allowSelectLivePhoto:allowSelectImage];
    
    return model;
}

#pragma mark - 根据照片数组对象获取对应photomodel数组
+ (NSArray<SJCPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto {
    return [self getPhotoInResult:result allowSelectVideo:allowSelectVideo allowSelectImage:allowSelectImage allowSelectGif:allowSelectGif allowSelectLivePhoto:allowSelectLivePhoto limitCount:NSIntegerMax];
}

+ (NSArray<SJCPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto limitCount:(NSInteger)limit {
    NSMutableArray<SJCPhotoModel *> *arrModel = [NSMutableArray array];
    __block NSInteger count = 1;
    [result enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SJCAssetMediaType type = [self transformAssetType:obj];
        
        if (type == SJCAssetMediaTypeImage && !allowSelectImage) return;
        if (type == SJCAssetMediaTypeGif && !allowSelectImage) return;
        if (type == SJCAssetMediaTypeLivePhoto && !allowSelectImage) return;
        if (type == SJCAssetMediaTypeVideo && !allowSelectVideo) return;
        
        if (count == limit) {
            *stop = YES;
        }
        
        NSString *duration = [self getDuration:obj];
        
        [arrModel addObject:[SJCPhotoModel modelWithAsset:obj type:type duration:duration]];
        count++;
    }];
    return arrModel;
}

//系统mediatype 转换为 自定义type
+ (SJCAssetMediaType)transformAssetType:(PHAsset *)asset {
    switch (asset.mediaType) {
        case PHAssetMediaTypeAudio:
            return SJCAssetMediaTypeAudio;
        case PHAssetMediaTypeVideo:
            return SJCAssetMediaTypeVideo;
        case PHAssetMediaTypeImage:
            if ([[asset valueForKey:@"filename"] hasSuffix:@"GIF"])return SJCAssetMediaTypeGif;
            
            if (@available(iOS 9.1, *)) {
                if (asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive || asset.mediaSubtypes == 10) return SJCAssetMediaTypeLivePhoto;
            }
            
            return SJCAssetMediaTypeImage;
        default:
            return SJCAssetMediaTypeUnknown;
    }
}

+ (NSString *)getDuration:(PHAsset *)asset{
    if (asset.mediaType != PHAssetMediaTypeVideo) return nil;
    
    NSInteger duration = (NSInteger)round(asset.duration);
    
    if (duration < 60) {
        return [NSString stringWithFormat:@"00:%02ld", duration];
    } else if (duration < 3600) {
        NSInteger m = duration / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld", m, s];
    } else {
        NSInteger h = duration / 3600;
        NSInteger m = (duration % 3600) / 60;
        NSInteger s = duration % 60;
        return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", h, m, s];
    }
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *image, NSDictionary *info))completion {
    return [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast progressHandler:progressHandler completion:completion];
}

+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion{
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    
    option.resizeMode = resizeMode;//控制照片尺寸
    //    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    option.networkAccessAllowed = YES;
    
    option.progressHandler = progressHandler;
    
    /*
     info字典提供请求状态信息:
     PHImageResultIsInCloudKey：图像是否必须从iCloud请求
     PHImageResultIsDegradedKey：当前UIImage是否是低质量的，这个可以实现给用户先显示一个预览图
     PHImageResultRequestIDKey和PHImageCancelledKey：请求ID以及请求是否已经被取消
     PHImageErrorKey：如果没有图像，字典内的错误信息
     */
    
    return [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        BOOL downloadFinined = ![[info objectForKey:PHImageCancelledKey] boolValue] && ![info objectForKey:PHImageErrorKey];
        //不要该判断，即如果该图片在iCloud上时候，会先显示一张模糊的预览图，待加载完毕后会显示高清图
        // && ![[info objectForKey:PHImageResultIsDegradedKey] boolValue]
        if (downloadFinined && completion) {
            completion(image, info);
        }
    }];
}


/**
 * @brief 获取视频
 */
+ (void)requestVideoForAsset:(PHAsset *)asset completion:(void (^ _Nullable)(AVPlayerItem *item, NSDictionary *info))completion {
    [self requestVideoForAsset:asset progressHandler:nil completion:completion];
}
+ (void)requestVideoForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^ _Nullable)(AVPlayerItem *item, NSDictionary *info))completion {
    PHVideoRequestOptions *option = [[PHVideoRequestOptions alloc] init];
    option.networkAccessAllowed = YES;
    option.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressHandler) {
                progressHandler(progress, error, stop, info);
            }
        });
    };
    [[PHCachingImageManager defaultManager] requestPlayerItemForVideo:asset options:option resultHandler:^(AVPlayerItem * _Nullable playerItem, NSDictionary * _Nullable info) {
        if (completion) completion(playerItem, info);
    }];
}


+ (void)markSelectModelInArr:(NSArray<SJCPhotoModel *> *)dataArr selArr:(NSArray<SJCPhotoModel *> *)selArr {
    NSMutableArray *selIdentifiers = [NSMutableArray array];
    for (SJCPhotoModel *m in selArr) {
        [selIdentifiers addObject:m.asset.localIdentifier];
    }
    for (SJCPhotoModel *m in dataArr) {
        if ([selIdentifiers containsObject:m.asset.localIdentifier]) {
            m.selected = YES;
        } else {
            m.selected = NO;
        }
    }
    
    [dataArr enumerateObjectsUsingBlock:^(SJCPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        for (SJCPhotoModel *m in selArr) {
            if ([m.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                obj.secletIndex = [selArr indexOfObject:m]+1;
                break;
            }
        }
    }];
}

+ (void)markSelectMode:(NSArray<SJCAlbumModel *>*)data selArr:(NSArray<SJCPhotoModel *> *)selArr {
    
    [data enumerateObjectsUsingBlock:^(SJCAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.models enumerateObjectsUsingBlock:^(SJCPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            for (SJCPhotoModel *m in selArr) {
                if ([m.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                    obj.secletIndex = m.secletIndex;
                    obj.selected = m.selected;
                    break;
                }
            }
        }];
    }];
    
    
}

+ (void)requestSelectedImageForAsset:(SJCPhotoModel *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion
{
    if (model.type == SJCAssetMediaTypeGif && allowSelectGif) {
        [self requestOriginalImageDataForAsset:model.asset progressHandler:nil completion:^(NSData *data, NSDictionary *info) {
            if (![[info objectForKey:PHImageResultIsDegradedKey] boolValue]) {
                UIImage *image = [SJCPhotoManager transformToGifImageWithData:data];
                if (completion) {
                    completion(image, info);
                }
            }
        }];
    } else {
        if (isOriginal) {
            [self requestOriginalImageForAsset:model.asset progressHandler:nil completion:completion];
        } else {
            CGFloat scale = 2;
            CGFloat width = MIN(SJC_WIDTH, SJCMaxImageWidth);
            CGSize size = CGSizeMake(width*scale, width*scale*model.asset.pixelHeight/model.asset.pixelWidth);
            [self requestImageForAsset:model.asset size:size progressHandler:nil completion:completion];
        }
    }
}

+ (void)requestOriginalImageForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^)(UIImage *, NSDictionary *))completion
{
    //    CGFloat scale = 4;
    //    CGFloat width = MIN(kViewWidth, kMaxImageWidth);
    //    CGSize size = CGSizeMake(width*scale, width*scale*asset.pixelHeight/asset.pixelWidth);
    //    [self requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeFast completion:completion];
    [self requestImageForAsset:asset size:CGSizeMake(asset.pixelWidth, asset.pixelHeight) resizeMode:PHImageRequestOptionsResizeModeNone progressHandler:progressHandler completion:completion];
}


+ (UIImage *)transformToGifImageWithData:(NSData *)data
{
    return [self sd_animatedGIFWithData:data];
}

+ (UIImage *)sd_animatedGIFWithData:(NSData *)data {
    if (!data) {
        return nil;
    }
    
    CGImageSourceRef source = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    size_t count = CGImageSourceGetCount(source);
    
    UIImage *animatedImage;
    
    if (count <= 1) {
        animatedImage = [[UIImage alloc] initWithData:data];
    } else {
        NSMutableArray *images = [NSMutableArray array];
        
        NSTimeInterval duration = 0.0f;
        
        for (size_t i = 0; i < count; i++) {
            CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
            
            duration += [self sd_frameDurationAtIndex:i source:source];
            
            [images addObject:[UIImage imageWithCGImage:image scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp]];
            
            CGImageRelease(image);
        }
        
        if (!duration) {
            duration = (1.0f / 10.0f) * count;
        }
        
        animatedImage = [UIImage animatedImageWithImages:images duration:duration];
    }
    
    CFRelease(source);
    
    return animatedImage;
}

+ (float)sd_frameDurationAtIndex:(NSUInteger)index source:(CGImageSourceRef)source {
    float frameDuration = 0.1f;
    CFDictionaryRef cfFrameProperties = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    NSDictionary *frameProperties = (__bridge NSDictionary *)cfFrameProperties;
    NSDictionary *gifProperties = frameProperties[(NSString *)kCGImagePropertyGIFDictionary];
    
    NSNumber *delayTimeUnclampedProp = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    if (delayTimeUnclampedProp) {
        frameDuration = [delayTimeUnclampedProp floatValue];
    } else {
        
        NSNumber *delayTimeProp = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTimeProp) {
            frameDuration = [delayTimeProp floatValue];
        }
    }
    
    // Many annoying ads specify a 0 duration to make an image flash as quickly as possible.
    // We follow Firefox's behavior and use a duration of 100 ms for any frames that specify
    // a duration of <= 10 ms. See <rdar://problem/7689300> and <http://webkit.org/b/36082>
    // for more information.
    
    if (frameDuration < 0.011f) {
        frameDuration = 0.100f;
    }
    
    CFRelease(cfFrameProperties);
    return frameDuration;
}

+ (UIImage *)scaleImage:(UIImage *)image original:(BOOL)original {
    NSData *data = UIImageJPEGRepresentation(image, 1);
    
    if (data.length < 0.2*(1024*1024)) {
        //小于200k不缩放
        return image;
    }
    
    double scale = original ? (data.length>(1024*1024)?.7:.9) : (data.length>(1024*1024)?.5:.7);
    NSData *d = UIImageJPEGRepresentation(image, scale);
    
    return [UIImage imageWithData:d];
    
    //    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    //    if (image.size.width < size.width
    //        ) {
    //        return image;
    //    }
    //    UIGraphicsBeginImageContext(size);
    //    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    //    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    //    UIGraphicsEndImageContext();
    //    return newImage;
}

#pragma mark - 权限相关
+ (BOOL)havePhotoLibraryAuthority{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusAuthorized) {
        return YES;
    }
    return NO;
}



+ (BOOL)haveCameraAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (BOOL)haveMicrophoneAuthority{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

+ (void)requestLargePhotoForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
           isShouldFixOrientation:(BOOL)isFixOrientation
                    resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    if (isFastMode) {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }else {
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        if (!resultHandler) return;
        
        /**
         
         * resultHandler中的info 字典提供了关于当前请求状态的信息，比如：
         
            - 图像是否必须从 iCloud 请求 (如果你初始化时将 networkAccessAllowed 设置成 false，那么就必须重新请求图像) —— PHImageResultIsInCloudKey 。
            - 当前递送的 UIImage 是否是最终结果的低质量格式。当高质量图像正在下载时，这个可以让你给用户先展示一个预览图像 —— PHImageResultIsDegradedKey。
            - 请求 ID (可以便捷的取消请求)，以及请求是否已经被取消。 —— PHImageResultRequestIDKey 和 PHImageCancelledKey。
            - 如果没有图像提供给 result handler，字典内还会有一个错误信息 —— PHImageErrorKey。
         
         */
        
        // Download image from iCloud / 从iCloud下载图片
        if (info[PHImageResultIsInCloudKey] && !image) {
            !resultHandler ? : resultHandler(asset, nil, info);
            PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
            option.networkAccessAllowed = YES;
            if (isFastMode) {
                option.resizeMode = PHImageRequestOptionsResizeModeFast;
                option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
            } else {
                option.resizeMode = PHImageRequestOptionsResizeModeExact;
                option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
            }
            [[PHImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                        ![info[PHImageCancelledKey] boolValue] &&
                                        ![info[PHImageResultIsDegradedKey] boolValue]);
                if (downloadFinined) {
                    UIImage *resultImage = [UIImage imageWithData:imageData scale:0.1];
                    if (resultImage) {
                        resultImage = [self resizeImage:resultImage size:targetSize];
                        if (isFixOrientation) resultImage = [self imageFixOrientation:resultImage];
                    }
                    resultHandler(asset, resultImage, info);
                } else {
                    resultHandler(asset, nil, info);
                }
            }];
            return;
        }
        
        BOOL downloadFinined = (!info[PHImageErrorKey] &&
                                ![info[PHImageCancelledKey] boolValue] &&
                                ![info[PHImageResultIsDegradedKey] boolValue]);
        
        if (downloadFinined && image && isFixOrientation) image = [self imageFixOrientation:image];
        
        resultHandler(asset, image, info);
    }];
}

+ (void)requestOriginalPhotoForAsset:(PHAsset *)asset
                          targetSize:(CGSize)targetSize
                          isFastMode:(BOOL)isFastMode
              isShouldFixOrientation:(BOOL)isFixOrientation
                 isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                       resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler {
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    if (isFastMode) {
        options.resizeMode = PHImageRequestOptionsResizeModeFast;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    }else {
        options.resizeMode = PHImageRequestOptionsResizeModeExact;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
            if (resultHandler) {
    //            if (isJustGetFinalPhoto) {
    //                BOOL downloadFinined = (!info[PHImageErrorKey] &&
    //                                        ![info[PHImageCancelledKey] boolValue] &&
    //                                        ![info[PHImageResultIsDegradedKey] boolValue]);
    //                if (downloadFinined) resultHandler(asset, image, info);
    //            } else {
                    resultHandler(asset, image, info);
    //            }
            }
        }];
}

#pragma mark - 图片处理

+ (UIImage *)imageFixOrientation:(UIImage *)image {
    
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)resizeImage:(UIImage *)image size:(CGSize)size {
    
    @autoreleasepool {
        UIGraphicsBeginImageContext(size);
        
        [image drawInRect:CGRectMake(0, 0, size.width + 1, size.height + 1)];
        
        UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return resizeImage;
    }
    
}
@end

