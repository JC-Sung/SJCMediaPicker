//
//  SJCMediaFilterController.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/30.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaFilterController.h"
#import "SJCMediaFilterCell.h"
#import <CoreImage/CoreImage.h>

//方式一
#import "ImageUtil.h"
#import "ColorMatrix.h"



@interface SJCMediaFilterController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIImageView *bigShowView;
@property (nonatomic, strong) UICollectionView *filterView;
@property (nonatomic, strong) NSMutableArray *filterTitleArr;
@property (nonatomic, strong) NSMutableArray <UIImage*>*filterImageArr;
@end

@implementation SJCMediaFilterController

/**
 *图片添加滤镜的方式有
 *
 *1.利用CoreImage库制作滤镜
 *2.GPUImage
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    self.bigShowView.image = self.orginImage;
    self.filterView.backgroundColor = UIColor.clearColor;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.filterTitleArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJCMediaFilterCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJCMediaFilterCellID" forIndexPath:indexPath];
    cell.title.text = self.filterTitleArr[indexPath.item];
    cell.img.image = self.filterImageArr[indexPath.item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.bigShowView.image = self.filterImageArr[indexPath.item];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(90, 90+30);
}

- (NSMutableArray *)filterTitleArr {
    if (!_filterTitleArr) {
        _filterTitleArr = @[@"原图",@"LOMO",@"黑白",@"复古",@"哥特",@"锐化",@"淡雅",@"酒红",@"清宁",@"浪漫",@"光晕",@"蓝调",@"梦幻",@"夜色"
        ].mutableCopy;
    }
    return _filterTitleArr;
}

- (NSMutableArray <UIImage *>*)filterImageArr {
    if (!_filterImageArr) {
        _filterImageArr = @[
            self.orginImage,
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_lomo],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_heibai],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_huajiu],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_gete],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_ruise],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_danya],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_jiuhong],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_qingning],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_langman],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_guangyun],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_landiao],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_menghuan],
            [ImageUtil imageWithImage:self.orginImage withColorMatrix:colormatrix_yese]
        ].mutableCopy;
    }
    return _filterImageArr;
}

- (void)chooseDoneAction {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    if (nav.cropDoneHandel) {
        nav.cropDoneHandel(self.bigShowView.image);
         [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 0, MIN(MAX([_doneBtn.titleLabel sjc_textWith]+12, 50), 150), 28);
        _doneBtn.layer.cornerRadius = 6;
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_doneBtn setTitle:@"完成" forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setBackgroundColor:themPinkColor];
        [_doneBtn addTarget:self action:@selector(chooseDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}


- (UIImageView *)bigShowView {
    if (!_bigShowView) {
        _bigShowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, SJCStatusBarAndNavigationBarHeight, SJC_WIDTH, SJC_WIDTH)];
        [self.view addSubview:_bigShowView];
    }
    return _bigShowView;
}

- (UICollectionView *)filterView {
    if (!_filterView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumInteritemSpacing = 2;
        layout.minimumLineSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20);
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        _filterView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.bigShowView.sjc_bottom+100, SJC_WIDTH, 120) collectionViewLayout:layout];
        _filterView.delegate = self;
        _filterView.dataSource = self;
        _filterView.alwaysBounceHorizontal = YES;
        _filterView.showsHorizontalScrollIndicator = NO;
        [_filterView registerClass:[SJCMediaFilterCell class] forCellWithReuseIdentifier:@"SJCMediaFilterCellID"];
        [self.view addSubview:_filterView];
    };
    return _filterView;
}

@end
