#import "UIView+SJCEasy.h"

@implementation UIView (SJCEasy)

- (CGFloat)sjc_left {
    return self.frame.origin.x;
}

- (void)setSjc_left:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)sjc_top {
    return self.frame.origin.y;
}

- (void)setSjc_top:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)sjc_right {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setSjc_right:(CGFloat)right {
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)sjc_bottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setSjc_bottom:(CGFloat)bottom {
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)sjc_width {
    return self.frame.size.width;
}

- (void)setSjc_width:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)sjc_height {
    return self.frame.size.height;
}

- (void)setSjc_height:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)sjc_centerX {
    return self.center.x;
}

- (void)setSjc_centerX:(CGFloat)centerX {
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)sjc_centerY {
    return self.center.y;
}

- (void)setSjc_centerY:(CGFloat)centerY {
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)sjc_origin {
    return self.frame.origin;
}

- (void)setSjc_origin:(CGPoint)origin {
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)sjc_size {
    return self.frame.size;
}

- (void)setSjc_size:(CGSize)size {
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

@end


@implementation UIView (SJCViewController)

- (UIViewController *)viewController{
    UIResponder *responder = self.nextResponder;
    do {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
        responder = responder.nextResponder;
    } while (responder);
    return nil;
}

@end

@implementation UILabel (SJCWith)

- (CGFloat)sjc_textWith {
    CGFloat stringWidth = 0;
    CGSize size = CGSizeMake(MAXFLOAT, MAXFLOAT);
    if (self.text.length > 0) {
#if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
        stringWidth =[self.text
                      boundingRectWithSize:size
                      options:NSStringDrawingUsesLineFragmentOrigin
                      attributes:@{NSFontAttributeName:self.font}
                      context:nil].size.width;
#else
        
        stringWidth = [self.titleLabel.text sizeWithFont:self.font
                             constrainedToSize:size
                                 lineBreakMode:NSLineBreakByCharWrapping].width;
#endif
    }
    return stringWidth;
}

- (CGFloat)sjc_textHight {
    CGFloat stringHight = 0;
    CGSize size = CGSizeMake(SJC_WIDTH, MAXFLOAT);
        if (self.text.length > 0) {
    #if defined(__IPHONE_OS_VERSION_MAX_ALLOWED) && __IPHONE_OS_VERSION_MAX_ALLOWED >= 70000
            stringHight =[self.text
                          boundingRectWithSize:size
                          options:NSStringDrawingUsesLineFragmentOrigin
                          attributes:@{NSFontAttributeName:self.font,NSForegroundColorAttributeName:self.textColor}
                          context:nil].size.height;
    #else
            
            stringHight = [self.text sizeWithFont:self.font
                                constrainedToSize:size
                                    lineBreakMode:NSLineBreakByCharWrapping].height;
    #endif
        }
        return stringHight;
}

@end

#import <objc/runtime.h>
@implementation UIButton (LargeClick)

- (UIEdgeInsets)touchAreaInsets{
    return [objc_getAssociatedObject(self, @selector(setTouchAreaInsets:)) UIEdgeInsetsValue];
}

- (void)setTouchAreaInsets:(UIEdgeInsets)touchAreaInsets{
    NSValue *value = [NSValue valueWithUIEdgeInsets:touchAreaInsets];
    objc_setAssociatedObject(self, @selector(setTouchAreaInsets:), value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event{
    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
    CGRect bounds = self.bounds;
    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
                        bounds.origin.y - touchAreaInsets.top,
                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
    return CGRectContainsPoint(bounds, point);
}

//- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
//    UIEdgeInsets touchAreaInsets = self.touchAreaInsets;
//    CGRect bounds = self.bounds;
//    bounds = CGRectMake(bounds.origin.x - touchAreaInsets.left,
//                        bounds.origin.y - touchAreaInsets.top,
//                        bounds.size.width + touchAreaInsets.left + touchAreaInsets.right,
//                        bounds.size.height + touchAreaInsets.top + touchAreaInsets.bottom);
//    if (CGRectEqualToRect(bounds, self.bounds)) {
//        return [super hitTest:point withEvent:event];
//    }
//    return CGRectContainsPoint(bounds, point) ? self : nil;
//}
@end


