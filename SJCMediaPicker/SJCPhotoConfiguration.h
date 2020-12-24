//
//  SJCPhotoConfiguration.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/16.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface SJCPhotoConfiguration : NSObject

- (instancetype)init NS_UNAVAILABLE;

+ (instancetype)defaultPhotoConfiguration;

/**
 最大选择数 默认9张，最小 1
 */
@property (nonatomic, assign) NSInteger maxSelectCount;
/**
 是否升序排列，预览界面不受该参数影响，默认升序 YES
 */
@property (nonatomic, assign) BOOL sortAscending;
/**
导航栏颜色
*/
@property (nonatomic, strong) UIColor *navTintColor;
/**
照片列数
*/
@property (nonatomic, assign) NSInteger columnNumber;
/**
照片之间的间距
*/
@property (nonatomic, assign) CGFloat columnMargin;
/**
 是否允许混合选择，即可以同时选择image(image/gif/livephoto)、video类型， 默认YES
 */
@property (nonatomic, assign) BOOL allowMixSelect;

/**
 是否允许选择照片 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectImage;

/**
 是否允许选择视频 默认YES
 */
@property (nonatomic, assign) BOOL allowSelectVideo;
/**
是否允许选择Gif，只是控制是否选择，并不控制是否显示，如果为NO，则不显示gif标识 默认YES
*/
@property (nonatomic, assign) BOOL allowSelectGif;
/**
显示每个相册里面已选择的数量 默认YES
*/
@property (nonatomic, assign) BOOL showEachAlbumSecletedCount;
/**
显示选中角标 默认YES
*/
@property (nonatomic, assign) BOOL showSecletIndex;
/**
是否需要裁剪 默认YES （当maxSelectCount为1时有效）
*/
@property (nonatomic, assign) BOOL allowCrop;
/**
裁剪时是否需要多功能编辑 默认NO
*/
@property (nonatomic, assign) BOOL allowMultiCrop;
/**
裁剪比例 默认1:1
*/
@property (nonatomic, assign) CGFloat cropScale;
/**
多裁剪比例 默认YES
*/
@property (nonatomic, assign) BOOL allowMultiScale;
/**
是否需要滤镜 默认YES
*/
@property (nonatomic, assign) BOOL needFilter;
@end


