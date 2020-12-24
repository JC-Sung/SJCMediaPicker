//
//  SJCMacro.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#ifndef SJCMacro_h
#define SJCMacro_h

#import "UIView+SJCEasy.h"
#import "UIColor+SJCExtension.h"
#import "SJCMediaPickerController.h"
#import "SJCPhotoManager.h"

#ifdef DEBUG
#define SJCLog(...) printf("%s %s 第%d行: %s\n", __TIME__, __FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);
#else
#define SJCLog(...)
#endif

#define WEAKSELF __weak typeof(self) weakSelf = self;
//尺寸
#define SJC_HEIGHT ((float)[[UIScreen mainScreen] bounds].size.height)
#define SJC_WIDTH ((float)[[UIScreen mainScreen] bounds].size.width)
#define SJC_SCALE    [[UIScreen mainScreen] scale]
#define SJC_BOUNDS   [[UIScreen mainScreen] bounds]
#define SJC_SIZE     [[UIScreen mainScreen] bounds].size
#define SJCOnePixelSize      (1 / [UIScreen mainScreen].scale)

//不建议设置太大，太大的话会导致图片加载过慢
#define SJCMaxImageWidth 500

//iPhone X适配
#define  SJCStatusTopMarginHeight      (IS_iPhoneX ? 44.f : 0.f)
#define  SJCStatusBarHeight      (IS_iPhoneX ? 44.f : 20.f)
#define  SJCNavigationBarHeight  44.f
#define  SJCTabbarHeight        (IS_iPhoneX ? (49.f+34.f) : 49.f)
#define  SJCTabbarSafeBottomMargin        (IS_iPhoneX ? 34.f : 0.f)
#define  SJCStatusBarAndNavigationBarHeight  (IS_iPhoneX ? 88.f : 64.f)

//颜色
#define SJCColorWithRGB(red, green, blue)          SJCColorWithRGBA(red, green, blue, 1.0)
#define SJCColorWithRGBA(RED, GREEN, BLUE, ALPHA) [UIColor colorWithRed:RED/255.0 green:GREEN/255.0 blue:BLUE/255.0 alpha:ALPHA]

#define dynamicColor(Light, Dark) [UIColor dynamicColorWithLight:Light dark:Dark]
#define themeGreen SJCColorWithRGB(77, 192, 105)
//下拉菜单相关

#define dropdownNavWith 200
#define dropdownNavHight 44.f
#define dropdownNavContainerHight 34
#define dropdownNavMargin 12
#define dropdownNavIconMargin 3
#define dropdownNavIconWith 13
#define dropdownNavIconhight 13


#define maxAxnum 5
#define cellHight 96

#ifndef sjc_weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define sjc_weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define sjc_weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define sjc_weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define sjc_weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef sjc_strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define sjc_strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define sjc_strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define sjc_strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define sjc_strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif



#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

/** 自定提醒窗口，自动消失 */
NS_INLINE void kAlertViewAutoDismiss(NSString *message, CGFloat delay){
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:nil, nil];
        [alerView show];
        [alerView performSelector:@selector(dismissWithClickedButtonIndex:animated:) withObject:@[@0, @1] afterDelay:delay];
    });
}

#pragma clang diagnostic pop

#endif /* SJCMacro_h */
