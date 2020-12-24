//
//  SJCDropdownMenuView.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SJCAlbumModel;
@interface SJCDropdownMenuView : UIView
@property (nonatomic, copy) void (^selectedAtIndex)(NSInteger index);
- (instancetype)initWithAlbums:(NSArray<SJCAlbumModel*>*)albums fatherView:(UIView *)containerView;
- (void)reloadAlbums:(NSArray<SJCAlbumModel*>*)albums andTitle:(NSString *)title;

@end

