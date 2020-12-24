//
//  SJCMediaPickerController.m
//  Yehwang
//
//  Created by 时光与你 on 2019/10/14.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaPickerController.h"
#import "SJCMediaShowController.h"

@interface SJCMediaPickerController ()

@end

@implementation SJCMediaPickerController

- (instancetype)init {
    return [self initWithPhotoConfiguration:[SJCPhotoConfiguration defaultPhotoConfiguration]];
}

- (instancetype)initWithPhotoConfiguration:(SJCPhotoConfiguration *)config {
    SJCMediaShowController *mainVc = [[SJCMediaShowController alloc] init];
    self = [super initWithRootViewController:mainVc];
    if (self) {
        //默认配置
        _configuration = config?config:[SJCPhotoConfiguration defaultPhotoConfiguration];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modalPresentationStyle = UIModalPresentationFullScreen;
    // Do any additional setup after loading the view.
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if (self.childViewControllers.count) { // 隐藏底部栏
        viewController.hidesBottomBarWhenPushed = YES;
        UIBarButtonItem *leftBtn = [self leftItemWithImageName:@"sjc_navback" target:self action:@selector(back) press:@selector(popToRootVC)];
        
        viewController.navigationItem.leftBarButtonItem = leftBtn;
        // 如果自定义返回按钮后, 滑动返回可能失效, 需要添加下面的代码
        __weak typeof(viewController)Weakself = viewController;
        self.interactivePopGestureRecognizer.delegate = (id)Weakself;
    }
    [super pushViewController:viewController animated:animated];
}

//普通返回
- (void)back{
    // 判断两种情况: push 和 present
    if ((self.presentedViewController || self.presentingViewController) && self.childViewControllers.count == 1) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }else
        [self popViewControllerAnimated:YES];
}
//长按返回顶层
- (void)popToRootVC{
    [self popToRootViewControllerAnimated:YES];
}

- (UIBarButtonItem *)leftItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action press:(SEL)press{
    UIView *leftCustomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SJCNavigationBarHeight+20, SJCNavigationBarHeight)];
    UIImageView *img = [[UIImageView alloc] initWithImage:[GetImageBundle(imageName) imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];
    img.tintColor = dynamicColor([UIColor blackColor], [UIColor whiteColor]);
    img.frame = CGRectMake(0, (SJCNavigationBarHeight-18)*0.5, 20, 18);
    [leftCustomView addSubview:img];
    leftCustomView.backgroundColor = [UIColor clearColor];
    leftCustomView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [leftCustomView addGestureRecognizer:tap];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:target action:press];
    longPress.minimumPressDuration = 0.8;
    [leftCustomView addGestureRecognizer:longPress];
    return [[UIBarButtonItem alloc] initWithCustomView:leftCustomView];
}

- (NSMutableArray<SJCPhotoModel *> *)arrSelectedModels{
    if (!_arrSelectedModels) {
        _arrSelectedModels = [NSMutableArray array];
    }
    return _arrSelectedModels;
}

- (NSMutableArray<NSString *> *)arrSelectedIds{
    if (!_arrSelectedIds) {
        _arrSelectedIds = [NSMutableArray array];
    }
    return _arrSelectedIds;
}
@end



