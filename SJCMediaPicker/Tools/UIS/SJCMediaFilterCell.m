//
//  SJCMediaFilterCell.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/30.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaFilterCell.h"
@interface SJCMediaFilterCell ()

@end

@implementation SJCMediaFilterCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupui];
    }
    return self;
}

- (void)setupui {
    self.backgroundColor = UIColor.clearColor;
    
    _title = [[UILabel alloc] init];
    _title.text = @"怀旧";
    _title.textColor = [UIColor lightGrayColor];
    _title.textAlignment = NSTextAlignmentCenter;
    _title.font = [UIFont systemFontOfSize:10];
    [self.contentView addSubview:_title];
    
    _img = [[UIImageView alloc] init];
    _img.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.contentView addSubview:_img];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _title.frame = CGRectMake(0, 0, self.contentView.frame.size.width, self.contentView.frame.size.height-self.contentView.frame.size.width);
    _img.frame = CGRectMake(0, self.contentView.frame.size.height-self.contentView.frame.size.width, self.contentView.frame.size.width, self.contentView.frame.size.width);
}

@end
