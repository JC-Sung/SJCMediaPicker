//
//  SJCMediaShowCell.h
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/14.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SJCPhotoModel;
@interface SJCMediaShowCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIImageView *videoImageView;
@property (nonatomic, strong) UIButton *btnSelect;
@property (nonatomic, strong) UILabel *indexLabe;
@property (nonatomic, strong) SJCPhotoModel *model;

@property (nonatomic, copy) void (^selectedBlock)(BOOL);
@end

NS_ASSUME_NONNULL_END
