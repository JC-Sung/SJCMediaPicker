//
//  SJCCropWHScaleView.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/30.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCCropWHScaleView.h"
#import "SJCMacro.h"
#import "SJCCropWHScaleCell.h"

@interface SJCCropWHScaleView ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UICollectionView *scaleChooseView;
@property (nonatomic, strong) NSMutableArray *scaleArr;
@end

static NSString *SJCCropWHScaleCellID = @"SJCCropWHScaleCell";

@implementation SJCCropWHScaleView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self initSubviews];
    }
    return self;
}

- (void)initSubviews {
    self.scaleChooseView.backgroundColor = UIColor.clearColor;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.scaleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJCCropWHScaleCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:SJCCropWHScaleCellID forIndexPath:indexPath];
    cell.info = self.scaleArr[indexPath.item];
    cell.secleted = [[self.scaleArr[indexPath.item] valueForKey:@"scale"] floatValue]==self.currentScale;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.currentScale = [[self.scaleArr[indexPath.item] valueForKey:@"scale"] floatValue];
    [collectionView reloadData];
    [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSecletWHScale:)]) {
        [self.delegate didSecletWHScale:[[self.scaleArr[indexPath.item] valueForKey:@"scale"] floatValue]];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake([self settingCollectionViewItemWidthBoundingWithText:[self.scaleArr[indexPath.item] valueForKey:@"title"]], 26);
}

- (CGFloat)settingCollectionViewItemWidthBoundingWithText:(NSString *)text{
    //1,设置内容大小  其中高度一定要与item一致,宽度度尽量设置大值
    CGSize size = CGSizeMake(MAXFLOAT, 26);
    //2,设置计算方式
    //3,设置字体大小属性   字体大小必须要与label设置的字体大小一致
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGRect frame = [text boundingRectWithSize:size options: NSStringDrawingUsesLineFragmentOrigin attributes:attributeDic context:nil];
    //4.添加左右间距
    return frame.size.width + 20;
}

- (NSMutableArray *)scaleArr {
    if (!_scaleArr) {
        _scaleArr = @[@{@"title":@"自由格式",@"scale":@(0.0)},
                      @{@"title":@"正方形",@"scale":@(1.0)},
                      @{@"title":@"16:9",@"scale":@(16.0/9.0)},
                      @{@"title":@"9:16",@"scale":@(9.0/16.0)},
                      @{@"title":@"8:10",@"scale":@(8.0/10.0)},
                      @{@"title":@"5:7",@"scale":@(5.0/7.0)},
                      @{@"title":@"3:4",@"scale":@(3.0/4.0)},
                      @{@"title":@"3:5",@"scale":@(3.0/5.0)},
                      @{@"title":@"2:3",@"scale":@(2.0/3.0)},
        ].mutableCopy;
    }
    return _scaleArr;
}

- (UICollectionView *)scaleChooseView {
    if (!_scaleChooseView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 10;
        layout.sectionInset = UIEdgeInsetsMake(17, 0, 17, 0);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _scaleChooseView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
        _scaleChooseView.delegate = self;
        _scaleChooseView.dataSource = self;
        _scaleChooseView.alwaysBounceHorizontal = YES;
        _scaleChooseView.showsHorizontalScrollIndicator = NO;
        [_scaleChooseView registerClass:[SJCCropWHScaleCell class] forCellWithReuseIdentifier:SJCCropWHScaleCellID];
        [self addSubview:_scaleChooseView];
    };
    return _scaleChooseView;
}
@end
