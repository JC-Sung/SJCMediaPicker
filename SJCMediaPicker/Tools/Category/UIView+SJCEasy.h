
#import <UIKit/UIKit.h>

@interface UIView (SJCEasy)

@property (nonatomic) CGFloat sjc_left;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat sjc_top;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat sjc_right;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat sjc_bottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat sjc_width;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat sjc_height;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat sjc_centerX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat sjc_centerY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint sjc_origin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  sjc_size;        ///< Shortcut for frame.size.

@end


@interface UIView (SJCViewController)

@property (readonly) UIViewController *viewController;

@end

@interface UILabel (SJCWith)

- (CGFloat)sjc_textWith;

- (CGFloat)sjc_textHight;

@end

@interface UIButton (SJCLargeClick)

@property (nonatomic, assign) UIEdgeInsets touchAreaInsets;

@end


