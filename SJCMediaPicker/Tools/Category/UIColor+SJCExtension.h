//
//  UIColor+SJCExtension.h
//  Commonuse
//
//  Created by 时光与你 on 2017/7/3.
//  Copyright © 2017年 song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (SJCExtension)

+ (UIColor *)colorWithHex:(uint)hex alpha:(CGFloat)alpha;

/**
 *  十六进制字符串转颜色
 */
+ (UIColor *)colorWithHexString:(NSString *)HexString;

+ (UIColor*) colorRGBonvertToHSB:(UIColor*)color withBrighnessDelta:(CGFloat)delta;

+ (UIColor*) colorRGBonvertToHSB:(UIColor*)color withAlphaDelta:(CGFloat)delta;

+ (UIColor*) colorWithHex:(NSInteger)hexValue;

+ (UIColor *)colorWithHexString:(NSString *)HexString alpha:(CGFloat)alpha;

+ (UIColor *)dynamicColorWithLight:(UIColor *)lightColor dark:(UIColor *)darkColor;
@end
