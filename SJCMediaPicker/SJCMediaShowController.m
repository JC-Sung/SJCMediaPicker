//
//  SJCMediaShowController.m
//  Yehwang
//
//  Created by 时光与你 on 2019/10/14.
//  Copyright © 2019 Yehwang. All rights reserved.
//
#import "SJCMediaPickerController.h"
#import "SJCMediaShowController.h"
#import "SJCMediaShowCell.h"
#import "SJCMacro.h"
#import "SJCDropdownMenuView.h"
#import "SJCPhotoManager.h"
#import "SJCMediaBrowseController.h"
#import "SJCAnimationTranstion.h"
#import "SJCInteractiveTrasition.h"
#import "SJCMediaCropController.h"
#import "SJCEditVideoController.h"

@interface SJCMediaShowController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPhotoLibraryChangeObserver, UINavigationControllerDelegate>
@property(assign,nonatomic) BOOL isfirstAppear;
@property (nonatomic, strong) UICollectionView *mainView;
@property(nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, assign) CGFloat columnMargin;
@property (nonatomic, strong) SJCDropdownMenuView *menuView;
@property (nonatomic, strong) NSMutableArray<SJCAlbumModel *>*albumArr;
@property (nonatomic, strong) NSMutableArray<SJCPhotoModel *> *arrDataSources;
@property (nonatomic, strong) UILabel *noAuthorityLab;
@property(assign,nonatomic) NSInteger albumSecletIndex;
@property (nonatomic, strong) UIButton *doneBtn;
@property (nonatomic, strong) UIButton *closeBtn;
@property(assign,nonatomic) BOOL isSelectOriginalPhoto;
@property (nonatomic, strong) SJCInteractiveTrasition *interactiveTrasition;
@end

@implementation SJCMediaShowController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.delegate = self;
    self.isfirstAppear = YES;
    self.albumSecletIndex = 0;
    self.isSelectOriginalPhoto = YES;
    SJCPhotoConfiguration *configuration = [(SJCMediaPickerController *)self.navigationController configuration];
    
    self.navigationController.navigationBar.tintColor = configuration.navTintColor;
    self.columnNumber = configuration.columnNumber;
    self.columnMargin = configuration.columnMargin;
    [SJCPhotoManager setSortAscending:configuration.sortAscending];
    [self.view addSubview:self.mainView];
    [self initNavSetting];
}

- (void)initNavSetting {
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.closeBtn];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    self.menuView = [[SJCDropdownMenuView alloc] initWithAlbums:self.albumArr fatherView:self.view];
       
    @sjc_weakify(self);
    self.menuView.selectedAtIndex = ^(NSInteger index) {
        @sjc_strongify(self);
        self.albumSecletIndex = index;
        [self getPhotoWithAlbum:index];
    };
    self.navigationItem.titleView = self.menuView;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //注册实施监听相册变化
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    if (![SJCPhotoManager havePhotoLibraryAuthority]) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusRestricted ||
            status == PHAuthorizationStatusDenied) {
        [self showNoAuthorityUI];
            return;
        } else if (status == PHAuthorizationStatusNotDetermined) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
                    if (status != PHAuthorizationStatusAuthorized) {
                        dispatch_sync(dispatch_get_main_queue(), ^{
                            [self showNoAuthorityUI];
                        });
                        return;
                    }
                }];
            });
        }
    }else {
        [self getAlbums];
    }
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    [self refreshDoneBtn:nav.arrSelectedModels.count];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance{
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (![SJCPhotoManager havePhotoLibraryAuthority]) {
            [self showNoAuthorityUI];
        } else {
            [self getAlbums];
        }
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    });
}

- (void)showNoAuthorityUI {
    self.noAuthorityLab.hidden = NO;
}

- (void)getAlbums {
    self.noAuthorityLab.hidden = YES;
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    SJCPhotoConfiguration *configuration = nav.configuration;
    @sjc_weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [SJCPhotoManager getPhotoAblumList:configuration.allowSelectVideo allowSelectImage:configuration.allowSelectImage complete:^(NSArray<SJCAlbumModel *> *albums) {
            @sjc_strongify(self);
            //重新复制需要还原选中的状态
            self.albumArr = [NSMutableArray arrayWithArray:albums];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.menuView reloadAlbums:self.albumArr andTitle:self.albumArr[self.albumSecletIndex].title];
                if (self.isfirstAppear) {
                    [self getPhotoWithAlbum:0];
                    self.isfirstAppear = NO;
                }
            });
        }];
    });
}

- (void)getPhotoWithAlbum:(NSInteger)index {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    [SJCPhotoManager markSelectModelInArr:self.albumArr[index].models selArr:nav.arrSelectedModels];
    _arrDataSources = [NSMutableArray arrayWithArray:self.albumArr[index].models];
    [self.mainView reloadData];
}

- (BOOL)canAddModel:(SJCPhotoModel *)model{
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    SJCPhotoConfiguration *configuration =nav.configuration;
    //最大选择数量限制
    if (nav.arrSelectedModels.count >= configuration.maxSelectCount) {
        UIAlertController *alter = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"你最多只能选择%ld张照片",(long)configuration.maxSelectCount] message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancle = [UIAlertAction actionWithTitle:SJCLocalized(@"OK") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alter addAction:cancle];
        [self presentViewController:alter animated:YES completion:nil];
        
        return NO;
    }
    //混合选择限制
    if (nav.arrSelectedModels.count > 0) {
        SJCPhotoModel *sm = nav.arrSelectedModels.firstObject;
        if (!configuration.allowMixSelect &&
            ((model.type < SJCAssetMediaTypeVideo && sm.type == SJCAssetMediaTypeVideo) || (model.type == SJCAssetMediaTypeVideo && sm.type < SJCAssetMediaTypeVideo))) {
            
            return NO;
        }
    }
    return YES;
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    
    SJCMediaShowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SJCMediaShowCellID" forIndexPath:indexPath];
    SJCPhotoModel *model = self.arrDataSources[indexPath.item];
    cell.model = model;
    
    @sjc_weakify(self);
    __weak typeof(cell) weakCell = cell;
    __weak typeof(nav) weakNav = nav;
    cell.selectedBlock = ^(BOOL selected) {
        @sjc_strongify(self);
        __strong typeof(weakCell) strongCell = weakCell;
        __strong typeof(weakNav) strongNav = weakNav;
        
        if (model.type == SJCAssetMediaTypeVideo) {
            if (strongNav.configuration.maxSelectCount == 1) {
                [self editVideo:model];
                return ;
            }
        } else if (model.type == SJCAssetMediaTypeImage ||
                   model.type == SJCAssetMediaTypeGif ||
                   model.type == SJCAssetMediaTypeLivePhoto) {
            if ((strongNav.configuration.maxSelectCount == 1) && (strongNav.configuration.allowCrop == YES)) {
                [self cropAction:model];
                return ;
            }
        }
        
        if (!selected) {
            //选中(在这里要做能否选中的各种判断逻辑)
            if (![self canAddModel:model]) return ;
            model.selected = YES;
            [strongNav.arrSelectedModels addObject:model];
            [strongNav.arrSelectedIds addObject:model.asset.localIdentifier];
            strongCell.btnSelect.selected = YES;
            if (strongNav.configuration.showSecletIndex) {
                
//                __block NSInteger index = 0;
//                [weakNav.arrSelectedModels enumerateObjectsUsingBlock:^(SJCPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                    if ([obj.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
//                        index = idx;
//                    }
//                }];
                
                //一定选中了
                model.secletIndex = [strongNav.arrSelectedIds indexOfObject:model.asset.localIdentifier]+1;
                strongCell.indexLabe.hidden = NO;
                strongCell.indexLabe.text = @([strongNav.arrSelectedIds indexOfObject:model.asset.localIdentifier] + 1).stringValue;
            }
        }else{
            model.selected = NO;
            strongCell.btnSelect.selected = NO;
            if (strongNav.configuration.showSecletIndex) {
                model.secletIndex = 0;
                strongCell.indexLabe.hidden = YES;
            }
            for (SJCPhotoModel *m in weakNav.arrSelectedModels) {
                if ([m.asset.localIdentifier isEqualToString:model.asset.localIdentifier]) {
                    [strongNav.arrSelectedModels removeObject:m];
                    [strongNav.arrSelectedIds removeObject:m.asset.localIdentifier];
                    break;
                }
            }
        }
        
        //当前选择的相册角标
        if (strongNav.configuration.showSecletIndex) {
            [self.arrDataSources enumerateObjectsUsingBlock:^(SJCPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                for (SJCPhotoModel *m in weakNav.arrSelectedModels) {
                    if ([m.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                        obj.secletIndex = [weakNav.arrSelectedIds indexOfObject:m.asset.localIdentifier]+1;
                        break;
                    }
                }
            }];
            if (selected) [collectionView reloadData];
        }
        //每个相册已选择的数量
        if (strongNav.configuration.showEachAlbumSecletedCount) {
            [self.albumArr enumerateObjectsUsingBlock:^(SJCAlbumModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                __block NSInteger count = 0;
                [obj.models enumerateObjectsUsingBlock:^(SJCPhotoModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    for (SJCPhotoModel *m in weakNav.arrSelectedModels) {
                        if ([m.asset.localIdentifier isEqualToString:obj.asset.localIdentifier]) {
                            count++;
                            break;
                        }
                    }
                }];
                obj.secletCount = count;
            }];
            [self.menuView reloadAlbums:self.albumArr andTitle:self.albumArr[self.albumSecletIndex].title];
        }
        
        [self refreshDoneBtn:nav.arrSelectedModels.count];
    };
    return cell;
}

- (void)refreshDoneBtn:(NSInteger)count {
    if (count) {
        [self.doneBtn setTitle:[NSString stringWithFormat:@"%@(%ld)",SJCLocalized(@"Complete"),count] forState:UIControlStateNormal];
        self.doneBtn.enabled = YES;
        [self.doneBtn setBackgroundColor:themPinkColor];
    }else{
        [self.doneBtn setTitle:SJCLocalized(@"Complete") forState:UIControlStateNormal];
        self.doneBtn.enabled = NO;
        [self.doneBtn setBackgroundColor:[themPinkColor colorWithAlphaComponent:0.6]];
    }
    _doneBtn.frame = CGRectMake(0, 0, MIN(MAX([_doneBtn.titleLabel sjc_textWith]+12, 50), 150), 28);
}

- (void)cropAction:(SJCPhotoModel *)model {
    SJCMediaCropController *vc = [SJCMediaCropController new];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)editVideo:(SJCPhotoModel *)model {
    SJCEditVideoController *vc = [SJCEditVideoController new];
    vc.model = model;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)chooseDoneAction {
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    
        __block NSMutableArray *photos = [NSMutableArray arrayWithCapacity:nav.arrSelectedModels.count];
        __block NSMutableArray *assets = [NSMutableArray arrayWithCapacity:nav.arrSelectedModels.count];
        
        __block NSMutableArray *errorAssets = [NSMutableArray array];
        __block NSMutableArray *errorIndexs = [NSMutableArray array];
        for (int i = 0; i < nav.arrSelectedModels.count; i++) {
            [photos addObject:@""];
            [assets addObject:@""];
        }
        @sjc_weakify(self);
        __block NSInteger doneCount = 0;
        for (int i = 0; i < nav.arrSelectedModels.count; i++) {
            SJCPhotoModel *model = nav.arrSelectedModels[i];
            [SJCPhotoManager requestSelectedImageForAsset:model isOriginal:self.isSelectOriginalPhoto allowSelectGif:nav.configuration.allowSelectGif completion:^(UIImage *image, NSDictionary *info) {
                @sjc_strongify(self);
                if (!self) return;
                doneCount++;
                if (image) {
                    [photos replaceObjectAtIndex:i withObject:[SJCPhotoManager scaleImage:image original:self.isSelectOriginalPhoto]];
                    [assets replaceObjectAtIndex:i withObject:model.asset];
                } else {
                    [errorAssets addObject:model.asset];
                    [errorIndexs addObject:@(i)];
                }
                
                if (doneCount < nav.arrSelectedModels.count) {
                    return;
                }
                
                NSMutableIndexSet *set = [[NSMutableIndexSet alloc] init];
                for (NSNumber *errorIndex in errorIndexs) {
                    [set addIndex:errorIndex.integerValue];
                }
                
                [photos removeObjectsAtIndexes:set];
                [assets removeObjectsAtIndexes:set];
                
            }];
        }
    if (nav.chooseDoneHandel) {
        nav.chooseDoneHandel(photos, assets, self.isSelectOriginalPhoto);
        [nav.arrSelectedModels removeAllObjects];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    SJCMediaPickerController *nav = (SJCMediaPickerController *)self.navigationController;
    
    SJCPhotoModel *model = self.arrDataSources[indexPath.item];
    
    //编辑视频
    if (model.type == SJCAssetMediaTypeVideo) {
        [self editVideo:model];
    } else if (model.type == SJCAssetMediaTypeImage ||
               model.type == SJCAssetMediaTypeGif ||
               model.type == SJCAssetMediaTypeLivePhoto) {
        if ((nav.configuration.maxSelectCount == 1) && (nav.configuration.allowCrop == YES)) {
            [self cropAction:model];
        }else {
            SJCMediaBrowseController *vc = [SJCMediaBrowseController new];
            vc.model = model;
            self.interactiveTrasition.presentingVC = vc;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}



- (void)closeAction {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (UICollectionView *)mainView {
    if (!_mainView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake((self.view.sjc_width-self.columnMargin*(self.columnNumber-1))/self.columnNumber, (self.view.sjc_width-self.columnMargin*(self.columnNumber-1))/self.columnNumber);
        layout.minimumLineSpacing = self.columnMargin;
        layout.minimumInteritemSpacing = self.columnMargin;
        layout.sectionInset = UIEdgeInsetsMake(kStatusBarAndNavigationBarHeight, 0, 0, 0);
        _mainView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
        _mainView.alwaysBounceVertical = YES;
        _mainView.delegate = self;
        _mainView.dataSource = self;
        _mainView.backgroundColor = [UIColor whiteColor];
        [_mainView registerClass:[SJCMediaShowCell class] forCellWithReuseIdentifier:@"SJCMediaShowCellID"];
    }
    return _mainView;
}

- (UICollectionViewCell *)targetCellForIndexPath:(NSIndexPath *)indexPath {
    NSInteger item = indexPath.item;
    NSInteger section = indexPath.section;
    return [self.mainView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:item inSection:section]];
}

- (UILabel *)noAuthorityLab {
    if (!_noAuthorityLab) {
        _noAuthorityLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, self.view.sjc_width-40, 100)];
        _noAuthorityLab.textColor = [UIColor blackColor];
        _noAuthorityLab.font = [UIFont boldSystemFontOfSize:14];
        _noAuthorityLab.textAlignment = NSTextAlignmentCenter;
        _noAuthorityLab.numberOfLines = 2;
        [self setLineSpace:8 withText:SJCLocalized(@"请在”设置-隐私-相机”选项中，允许访问你的相机") inLabel:_noAuthorityLab];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openSetting)];
        _noAuthorityLab.userInteractionEnabled = YES;
        [_noAuthorityLab addGestureRecognizer:tap];
        [self.view addSubview:_noAuthorityLab];
        [self.view bringSubviewToFront:_noAuthorityLab];
    }
    return _noAuthorityLab;
}

- (UIButton *)doneBtn {
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 0, 60, 28);
        _doneBtn.layer.cornerRadius = 6;
        _doneBtn.layer.masksToBounds = YES;
        _doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_doneBtn setTitle:SJCLocalized(@"Complete") forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_doneBtn setBackgroundColor:themPinkColor];
        [_doneBtn addTarget:self action:@selector(chooseDoneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        _closeBtn.frame = CGRectMake(0, 0, 60, 28);
        _closeBtn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [_closeBtn setTitle:SJCLocalized(@"Cancle") forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_closeBtn setTitleColor:themPinkColor forState:UIControlStateHighlighted];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

-(void)setLineSpace:(CGFloat)lineSpace withText:(NSString *)text inLabel:(UILabel *)label{
    if (!text || !label) {
        return;
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = lineSpace;  //设置行间距
    paragraphStyle.lineBreakMode = label.lineBreakMode;
    paragraphStyle.alignment = label.textAlignment;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [text length])];
//    [attributedString addAttribute:NSForegroundColorAttributeName value:SJCColorWithRGB(88, 177, 117) range:NSMakeRange(9, 10)];
    label.attributedText = attributedString;
}

- (void)openSetting {
    // 去设置界面，开启相机访问权限
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }else{
        // [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Privacy&path=Photos"]];
        
    }
}

#pragma mark - transition
#pragma mark <UINavigationControllerDelegate>
- (id <UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    
    //只在大图浏览的时候才会启用转场动画
    if (([fromVC isKindOfClass:[SJCMediaShowController class]]&&[toVC isKindOfClass:[SJCMediaBrowseController class]])||([fromVC isKindOfClass:[SJCMediaBrowseController class]]&&[toVC isKindOfClass:[SJCMediaShowController class]])) {
        return [SJCAnimationTranstion sjcAnimationTranstionWithType:operation];
    }else {
        return nil;
    }
}

- (id <UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    
    return self.interactiveTrasition.isInteractive? self.interactiveTrasition: nil;
}

- (SJCInteractiveTrasition *)interactiveTrasition {
    if (!_interactiveTrasition) {
        _interactiveTrasition = [SJCInteractiveTrasition new];
    }
    return _interactiveTrasition;
}
@end


