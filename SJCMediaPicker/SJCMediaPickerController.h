//
//  SJCMediaPickerController.h
//  Yehwang
//
//  Created by 时光与你 on 2019/10/14.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SJCPhotoConfiguration.h"
#import "SJCPhotoModel.h"
#import "SJCMacro.h"

typedef void (^didFinishPickingPhotosHandle)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto);
typedef void (^didCropPhotosHandle)(UIImage *image);

@interface SJCMediaPickerController : UINavigationController
- (instancetype)initWithRootViewController:(UIViewController *)rootViewController NS_UNAVAILABLE;
- (instancetype)initWithPhotoConfiguration:(SJCPhotoConfiguration *)config;
//选择完照片的回调
@property (nonatomic, copy) didFinishPickingPhotosHandle chooseDoneHandel;
//裁剪完照片的回调（因为只想得到裁剪后的照片，不想保存到系统相册）
@property (nonatomic, copy) didCropPhotosHandle cropDoneHandel;
/**
 相册框架配置
 */
@property (nonatomic, strong) SJCPhotoConfiguration *configuration;

@property (nonatomic, copy) NSMutableArray<SJCPhotoModel *> *arrSelectedModels;
@property (nonatomic, copy) NSMutableArray<NSString *> *arrSelectedIds;
@end


