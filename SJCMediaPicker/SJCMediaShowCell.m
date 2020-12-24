//
//  SJCMediaShowCell.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/14.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaShowCell.h"
#import "SJCMacro.h"

@interface SJCMediaShowCell ()

@end

@implementation SJCMediaShowCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUi];
    }
    return self;
}

- (void)setupUi{
    [self.contentView addSubview:self.imageView];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.videoImageView];
    [self.contentView addSubview:self.btnSelect];
    [self.contentView addSubview:self.indexLabe];
}

- (void)setModel:(SJCPhotoModel *)model {
    _model = model;
    
    if (model.type == SJCAssetMediaTypeVideo) {
        self.videoImageView.hidden = NO;
        self.timeLabel.hidden = NO;
        self.timeLabel.text = model.duration;
    } else if (model.type == SJCAssetMediaTypeGif) {
        self.videoImageView.hidden = YES;
        self.timeLabel.text = @"GIF";
    } else if (model.type == SJCAssetMediaTypeLivePhoto) {
        self.videoImageView.hidden = YES;
        self.timeLabel.text = @"Live";
    } else {
        self.videoImageView.hidden = YES;
        self.timeLabel.hidden = YES;
    }
    
    self.btnSelect.selected = model.isSelected;
    self.indexLabe.hidden = !model.secletIndex;
    self.indexLabe.text = [NSString stringWithFormat:@"%ld",model.secletIndex];
    
    @sjc_weakify(self);
    [SJCPhotoManager requestImageForAsset:model.asset size:CGSizeMake(self.sjc_width*2.5, self.sjc_width*2.5) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @sjc_strongify(self);
        self.imageView.image = image;
    }];
}

- (void)btnSelectClick:(UIButton *)sender {
    if (!self.btnSelect.selected) {
        [self.btnSelect.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        [self.indexLabe.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    }
    if (self.selectedBlock) {
        self.selectedBlock(self.btnSelect.selected);
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.frame = self.contentView.bounds;
    self.videoImageView.frame = CGRectMake(8, self.sjc_height-10-8, 10, 10);
    self.timeLabel.frame = CGRectMake(self.sjc_width-100-6, self.sjc_height-10-8, 100, 10);
    self.btnSelect.frame = CGRectMake(self.sjc_width-20-6, 6, 20, 20);
    self.indexLabe.frame = CGRectMake(self.sjc_width-20-6, 6, 20, 20);
}

- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIImageView *)videoImageView {
    if (!_videoImageView) {
        _videoImageView = [[UIImageView alloc] initWithImage:GetImageBundle(@"sjc_video")];
        _videoImageView.contentMode = UIViewContentModeScaleAspectFill;
        _videoImageView.hidden = YES;
    }
    return _videoImageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [UILabel new];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:10];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        _timeLabel.hidden = YES;
    }
    return _timeLabel;
}

- (UIButton *)btnSelect {
    if (!_btnSelect) {
        _btnSelect = [UIButton buttonWithType:UIButtonTypeCustom];
        [_btnSelect setBackgroundImage:GetImageBundle(@"sjc_btn_unselected") forState:UIControlStateNormal];
        [_btnSelect setBackgroundImage:GetImageBundle(@"sjc_btn_selected") forState:UIControlStateSelected];
        _btnSelect.tintColor = SJCColorWithRGB(77, 192, 105);
        _btnSelect.touchAreaInsets = UIEdgeInsetsMake(6, 10, 10, 6);
        [_btnSelect addTarget:self action:@selector(btnSelectClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _btnSelect;
}

- (UILabel *)indexLabe {
    if (!_indexLabe) {
        _indexLabe = [UILabel new];
        _indexLabe.layer.cornerRadius = 10;
        _indexLabe.layer.masksToBounds = YES;
        _indexLabe.textColor = [UIColor whiteColor];
        _indexLabe.font = [UIFont systemFontOfSize:10];
        _indexLabe.textAlignment = NSTextAlignmentCenter;
        _indexLabe.backgroundColor = themPinkColor;
        _indexLabe.hidden = YES;
    }
    return _indexLabe;
}
@end
