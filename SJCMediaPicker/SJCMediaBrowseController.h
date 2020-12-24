//
//  SJCMediaBrowseController.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SJCPhotoModel;

@interface SJCMediaBrowseController : UIViewController

@property (nonatomic, strong) SJCPhotoModel *model;
@property (nonatomic, strong) UIImageView *browseImageView;
@end


