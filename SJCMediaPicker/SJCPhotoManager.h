//
//  SJCPhotoManager.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SJCPhotoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SJCPhotoManager : NSObject

+ (void)setSortAscending:(BOOL)ascending;

/**
* @brief 获取用户所有相册列表
*/
+ (void)getPhotoAblumList:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage complete:(void (^ _Nullable)(NSArray<SJCAlbumModel *> *))complete;

/**
 * @brief 将result中对象转换成SJCPhotoModel
 */
+ (NSArray<SJCPhotoModel *> *)getPhotoInResult:(PHFetchResult<PHAsset *> *)result allowSelectVideo:(BOOL)allowSelectVideo allowSelectImage:(BOOL)allowSelectImage allowSelectGif:(BOOL)allowSelectGif allowSelectLivePhoto:(BOOL)allowSelectLivePhoto;

/**
 * @brief 获取选中的图片
 */
+ (void)requestSelectedImageForAsset:(SJCPhotoModel *)model isOriginal:(BOOL)isOriginal allowSelectGif:(BOOL)allowSelectGif completion:(void (^)(UIImage *, NSDictionary *))completion;
/**
 获取原图data，转换gif图
 */
+ (void)requestOriginalImageDataForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^ _Nullable)(NSData *, NSDictionary *))completion;

/**
 * @brief 获取原图
 */
+ (void)requestOriginalImageForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^ _Nullable)(UIImage *, NSDictionary *))completion;

/**
* @brief 根据传入size获取图片
*/
+ (PHImageRequestID)requestImageForAsset:(PHAsset *)asset size:(CGSize)size progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^ _Nullable)(UIImage *, NSDictionary *))completion;

/**
 * @brief 获取视频
 */
+ (void)requestVideoForAsset:(PHAsset *)asset completion:(void (^ _Nullable)(AVPlayerItem *item, NSDictionary *info))completion;
+ (void)requestVideoForAsset:(PHAsset *)asset progressHandler:(void (^ _Nullable)(double progress, NSError *error, BOOL *stop, NSDictionary *info))progressHandler completion:(void (^ _Nullable)(AVPlayerItem *item, NSDictionary *info))completion;

/**
 * @brief 标记源数组中已被选择的model
 */
+ (void)markSelectModelInArr:(NSArray<SJCPhotoModel *> *)dataArr selArr:(NSArray<SJCPhotoModel *> *)selArr;

+ (void)markSelectMode:(NSArray<SJCAlbumModel *>*)data selArr:(NSArray<SJCPhotoModel *> *)selArr;
/**
 @brief 缩放图片
 */
+ (UIImage *)scaleImage:(UIImage *)image original:(BOOL)original;

#pragma mark - 相册、相机、麦克风权限相关
/**
 是否有相册访问权限
 */
+ (BOOL)havePhotoLibraryAuthority;

/**
 是否有相机访问权限
 */
+ (BOOL)haveCameraAuthority;

/**
 是否有麦克风访问权限
 */
+ (BOOL)haveMicrophoneAuthority;

+ (void)requestLargePhotoForAsset:(PHAsset *)asset
                       targetSize:(CGSize)targetSize
                       isFastMode:(BOOL)isFastMode
           isShouldFixOrientation:(BOOL)isFixOrientation
                    resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler;

+ (void)requestOriginalPhotoForAsset:(PHAsset *)asset
                          targetSize:(CGSize)targetSize
                          isFastMode:(BOOL)isFastMode
              isShouldFixOrientation:(BOOL)isFixOrientation
                 isJustGetFinalPhoto:(BOOL)isJustGetFinalPhoto
                       resultHandler:(void (^)(PHAsset *requestAsset, UIImage *result, NSDictionary *info))resultHandler;
@end

NS_ASSUME_NONNULL_END

