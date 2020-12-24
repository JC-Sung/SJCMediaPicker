//
//  SJCDropdownMenuView.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/15.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCDropdownMenuView.h"
#import "SJCMacro.h"
#import "SJCPhotoModel.h"
#import "SJCPhotoManager.h"

@interface SJCDropdownMenuCell : UITableViewCell
@property (nonatomic, strong) SJCAlbumModel *model;
@property (strong, nonatomic) UIImageView *posterImageView;
@property (nonatomic, strong) UIView *backView;
@property (strong, nonatomic) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *badegeLabel;
@property (strong, nonatomic) UIImageView *markImageView;
@end

@implementation SJCDropdownMenuCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.tintColor = [UIColor blackColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        [self setupUIS];
    }
    return self;
}

- (void)setupUIS {
    self.titleLabel.textColor = [UIColor blackColor];
    self.markImageView.tintColor = themPinkColor;
    self.badegeLabel.backgroundColor = themPinkColor;
}

- (void)setModel:(SJCAlbumModel *)model {
    _model = model;
    NSMutableAttributedString *nameString = [[NSMutableAttributedString alloc] initWithString:model.title attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor blackColor]}];
    NSAttributedString *countString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  (%ld)",model.count] attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
    [nameString appendAttributedString:countString];
    self.titleLabel.attributedText = nameString;
    self.badegeLabel.hidden = !model.secletCount;
    self.badegeLabel.text = [NSString stringWithFormat:@"%ld",model.secletCount];
    @sjc_weakify(self);
    [SJCPhotoManager requestImageForAsset:model.headImageAsset size:CGSizeMake(self.sjc_width*2.5, self.sjc_width*2.5) progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @sjc_strongify(self);
        self.posterImageView.image = image;
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.posterImageView.frame = CGRectMake(20, 16, 70, 70);
    self.backView.frame = CGRectMake(self.posterImageView.sjc_right-6, 22, 12, 58);
    NSInteger titleHeight = ceil(self.titleLabel.font.lineHeight);
    self.titleLabel.frame = CGRectMake(70+20+16, (self.sjc_height - titleHeight) / 2, self.sjc_width - 70 - 50, titleHeight);
    self.markImageView.frame = CGRectMake(self.sjc_width-16-18, (self.sjc_height - 16) / 2, 18, 16);
    self.badegeLabel.frame = CGRectMake(self.posterImageView.sjc_right-MAX([self.badegeLabel sjc_textWith]+10, 20)*0.5, (self.posterImageView.sjc_top - 10), MAX([self.badegeLabel sjc_textWith]+10, 20), 20);
}

- (UIImageView *)posterImageView {
    if (_posterImageView == nil) {
        UIImageView *posterImageView = [[UIImageView alloc] init];
        posterImageView.contentMode = UIViewContentModeScaleAspectFill;
        posterImageView.clipsToBounds = YES;
        posterImageView.layer.cornerRadius = 6;
        posterImageView.layer.masksToBounds = YES;
        posterImageView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView insertSubview:posterImageView atIndex:0];
        _posterImageView = posterImageView;
    }
    return _posterImageView;
}

- (UIView *)backView {
    if (!_backView) {
        _backView = [UIView new];
        _backView.layer.cornerRadius = 6;
        _backView.layer.masksToBounds = YES;
        _backView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [self.contentView insertSubview:_backView belowSubview:_posterImageView];
    }
    return _backView;
}

- (UILabel *)titleLabel {
    if (_titleLabel == nil) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:14];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)badegeLabel {
    if (!_badegeLabel) {
        _badegeLabel = [UILabel new];
        _badegeLabel.textAlignment = NSTextAlignmentCenter;
        _badegeLabel.font = [UIFont systemFontOfSize:9];
        _badegeLabel.textColor = UIColor.whiteColor;
        _badegeLabel.layer.cornerRadius = 10;
        _badegeLabel.layer.masksToBounds = YES;
        _badegeLabel.layer.borderWidth = 1.5;
        _badegeLabel.layer.borderColor = [UIColor whiteColor].CGColor;
        _badegeLabel.hidden = YES;
        [self.contentView addSubview:_badegeLabel];
    }
    return _badegeLabel;
}

- (UIImageView *)markImageView {
    if (!_markImageView) {
        _markImageView = [[UIImageView alloc] initWithImage:[GetImageBundle(@"sjc_checkmark") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _markImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_markImageView];
    }
    return _markImageView;
}

@end

@interface SJCDropdownMenuView ()<UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, copy) NSArray <SJCAlbumModel*>*albumSouce;
@property (nonatomic, assign) BOOL isMenuShow;
@property (nonatomic, strong) UIView *navContainer;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, strong) UIView *container;
@end

@implementation SJCDropdownMenuView

- (instancetype)initWithAlbums:(NSArray<SJCAlbumModel*>*)albums fatherView:(UIView *)containerView {
    self = [super initWithFrame:CGRectMake(0, 0, dropdownNavWith, dropdownNavHight)];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        _container = containerView;
        _selectedIndex = 0;
        _albumSouce = albums;
        [self addSubview:self.navContainer];
        [self.navContainer addSubview:self.titleLabel];
        [self.navContainer addSubview:self.arrowImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapOnTitleButton)];
        self.userInteractionEnabled = YES;
        [self addGestureRecognizer:tap];
        [self.maskView addSubview:self.tableView];
        [self.maskView bringSubviewToFront:self.tableView];
        [self.container addSubview:self.maskView];
        [self.container bringSubviewToFront:self.maskView];
        self.maskView.hidden = YES;
        self.tableView.hidden = YES;
        
    }
    return self;
}

- (void)reloadAlbums:(NSArray<SJCAlbumModel*>*)albums andTitle:(NSString *)title {
    _albumSouce = albums;
    self.titleLabel.text = title;
    [self.tableView reloadData];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.navContainer.frame = CGRectMake((self.sjc_width-MIN(dropdownNavWith, dropdownNavMargin*2+dropdownNavIconWith+dropdownNavIconMargin+[self.titleLabel sjc_textWith]))*0.5, (self.sjc_height-dropdownNavContainerHight)*0.5, MIN(dropdownNavWith, dropdownNavMargin*2+dropdownNavIconWith+dropdownNavIconMargin+[self.titleLabel sjc_textWith]), dropdownNavContainerHight);
    self.titleLabel.frame = CGRectMake(dropdownNavMargin, 0, MIN([self.titleLabel sjc_textWith], dropdownNavWith-dropdownNavMargin*2-dropdownNavIconMargin-dropdownNavIconWith), dropdownNavContainerHight);
    self.arrowImageView.frame = CGRectMake(self.titleLabel.sjc_right+dropdownNavIconMargin, (dropdownNavContainerHight-dropdownNavIconhight)*0.5, dropdownNavIconWith, dropdownNavIconhight);
}

- (void)dealloc{

}

#pragma mark  UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.albumSouce.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return cellHight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SJCDropdownMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SJCDropdownMenuCellID" forIndexPath:indexPath];
    cell.markImageView.hidden = self.selectedIndex != indexPath.row;
    cell.model = self.albumSouce[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.row;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.isMenuShow = NO;
    !_selectedAtIndex ? : _selectedAtIndex(indexPath.row);
}

- (void)handleTapOnTitleButton {
    if (_albumSouce.count) {
        self.isMenuShow = !self.isMenuShow;
    }
}

- (void)showMenu{
    self.maskView.hidden = NO;
    self.tableView.hidden = NO;
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
                     animations:^{
        //如果是- M_PI的话，箭头会转一圈而不是原路返回
                         self.arrowImageView.transform = CGAffineTransformMakeRotation(0.000001 - M_PI);
                     }];
    self.tableView.frame = CGRectMake(0, 0, SJC_WIDTH, 0);
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0.35 options:(7 << 16) animations:^{
        self.tableView.sjc_height = self->_albumSouce.count>maxAxnum?cellHight*maxAxnum:cellHight*self->_albumSouce.count;
        self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3f];
    } completion:^(BOOL finished) {
        self.userInteractionEnabled = YES;
    }];
}

- (void)hideMenu{
    self.userInteractionEnabled = NO;
    [UIView animateWithDuration:0.3
    animations:^{
        self.arrowImageView.transform = CGAffineTransformIdentity;
    }];
    [UIView animateWithDuration:0.3 animations:^{
    self.tableView.sjc_height = 0;;
    self.maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
} completion:^(BOOL finished) {
    self.maskView.hidden = YES;
    self.tableView.hidden = YES;
    self.userInteractionEnabled = YES;
    [self.tableView reloadData];
}];
    
}

- (UIView *)navContainer {
    if (!_navContainer) {
        _navContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 30)];
        _navContainer.backgroundColor = [UIColor clearColor];
        _navContainer.layer.cornerRadius = dropdownNavContainerHight*0.5;
        _navContainer.layer.masksToBounds = YES;
        _navContainer.clipsToBounds = YES;
    }
    return _navContainer;
}

- (UILabel *)titleLabel {
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"最近项目";
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = dynamicColor([UIColor blackColor], [UIColor whiteColor]);
    }
    return _titleLabel;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView){
        _arrowImageView = [[UIImageView alloc] initWithImage:[GetImageBundle(@"sjc_xiangxiajiantou") imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
        _arrowImageView.tintColor = [UIColor blackColor];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _arrowImageView;
}

- (UITableView *)tableView {
    if (!_tableView){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, SJC_WIDTH, 100) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.tableHeaderView = [[UIView alloc] init];
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[SJCDropdownMenuCell class] forCellReuseIdentifier:@"SJCDropdownMenuCellID"];
    }
    return _tableView;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:CGRectMake(0, SJCStatusBarAndNavigationBarHeight, SJC_WIDTH, SJC_HEIGHT-SJCStatusBarAndNavigationBarHeight)];
        _maskView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.0f];
        _maskView.clipsToBounds = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction)];
        tapGesture.numberOfTapsRequired = 1;
        tapGesture.delegate = self;
        [self.maskView addGestureRecognizer:tapGesture];
    }
    return _maskView;
}

- (void)setIsMenuShow:(BOOL)isMenuShow{
    if (_isMenuShow != isMenuShow){
        _isMenuShow = isMenuShow;
        if (isMenuShow){
            [self showMenu];
        }
        else{
            [self hideMenu];
        }
    }
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex{
    if (_selectedIndex != selectedIndex){
        _selectedIndex = selectedIndex;
        _titleLabel.text = [[_albumSouce objectAtIndex:selectedIndex] title];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.navContainer.frame = CGRectMake((self.sjc_width-MIN(dropdownNavWith, dropdownNavMargin*2+dropdownNavIconWith+dropdownNavIconMargin+[self.titleLabel sjc_textWith]))*0.5, (self.sjc_height-dropdownNavContainerHight)*0.5, MIN(dropdownNavWith, dropdownNavMargin*2+dropdownNavIconWith+dropdownNavIconMargin+[self.titleLabel sjc_textWith]), dropdownNavContainerHight);
            self.titleLabel.frame = CGRectMake(dropdownNavMargin, 0, MIN([self.titleLabel sjc_textWith], dropdownNavWith-dropdownNavMargin*2-dropdownNavIconMargin-dropdownNavIconWith), dropdownNavContainerHight);
            self.arrowImageView.frame = CGRectMake(self.titleLabel.sjc_right+dropdownNavIconMargin, (dropdownNavContainerHight-dropdownNavIconhight)*0.5, dropdownNavIconWith, dropdownNavIconhight);
        }];
    }
    self.isMenuShow = NO;
}

- (void)tapGestureAction {
    self.isMenuShow = NO;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([touch.view isDescendantOfView:self.tableView]) {
        return NO;
    }
    return YES;
}
@end




