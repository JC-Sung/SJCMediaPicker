//
//  SJCMediaBrowseController.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCMediaBrowseController.h"
#import "SJCMacro.h"

@interface SJCMediaBrowseController ()
@property (nonatomic, strong) UIView *closeBtn;
@end

@implementation SJCMediaBrowseController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.browseImageView.backgroundColor = UIColor.clearColor;
    self.closeBtn.backgroundColor = UIColor.clearColor;
    @sjc_weakify(self);
    [SJCPhotoManager requestImageForAsset:self.model.asset size:self.view.bounds.size progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @sjc_strongify(self);
        self.browseImageView.image = image;
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.browseImageView.frame = self.view.bounds;
}

- (UIImageView *)browseImageView {
    if (!_browseImageView) {
        _browseImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _browseImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.view addSubview:_browseImageView];
    }
    return _browseImageView;
}

- (UIView *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [self leftItemWithImageName:@"sjc_navback" target:self action:@selector(closeAction) press:@selector(closeAction)];
        _closeBtn.frame = CGRectMake(20, SJCStatusBarHeight, SJCNavigationBarHeight+20, SJCNavigationBarHeight);
        [self.view addSubview:_closeBtn];
    }
    return _closeBtn;
}

- (void)closeAction {
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIView *)leftItemWithImageName:(NSString *)imageName target:(id)target action:(SEL)action press:(SEL)press{
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
    return leftCustomView;
}
@end
