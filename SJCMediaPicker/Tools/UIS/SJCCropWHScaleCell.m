//
//  SJCCropWHScaleCell.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/30.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCCropWHScaleCell.h"

@interface SJCCropWHScaleCell ()
@property (nonatomic, strong) UILabel *title;
@end

@implementation SJCCropWHScaleCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupui];
    }
    return self;
}

- (void)setupui {
    _title = [[UILabel alloc] initWithFrame:self.contentView.bounds];
    _title.textColor = UIColor.whiteColor;
    _title.textAlignment = NSTextAlignmentCenter;
    _title.font = [UIFont systemFontOfSize:14];
    _title.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    _title.layer.cornerRadius = 13;
    _title.layer.masksToBounds = YES;
    [self.contentView addSubview:_title];
}

- (void)setInfo:(NSDictionary *)info {
    _info = info;
    _title.text = [info valueForKey:@"title"];
}

- (void)setSecleted:(BOOL)secleted {
    _secleted = secleted;
    if (secleted) {
        _title.textColor = UIColor.whiteColor;
        _title.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    }else {
        _title.textColor = [UIColor lightTextColor];
        _title.backgroundColor = UIColor.clearColor;
    }
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _title.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height);
}
@end
