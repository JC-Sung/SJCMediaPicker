//
//  SJCAnimationTranstion.m
//  SJCMediaPicker
//
//  Created by 时光与你 on 2019/10/28.
//  Copyright © 2019 Yehwang. All rights reserved.
//

#import "SJCAnimationTranstion.h"
#import "SJCMediaShowController.h"
#import "SJCMediaBrowseController.h"
#import "SJCMediaShowCell.h"
#import "SJCMacro.h"

@interface SJCMediaShowController ()
/**collectionview*/
@property (nonatomic, strong)UICollectionView *mainView;
@property(nonatomic,strong)NSIndexPath *indexPath;
- (UICollectionViewCell *)targetCellForIndexPath:(NSIndexPath *)indexPath;
@end

@interface SJCAnimationTranstion ()
@property(assign,nonatomic) SJCTransitionType transitionType;
@end

@implementation SJCAnimationTranstion

+ (instancetype)sjcAnimationTranstionWithType:(SJCTransitionType)type {
    
    if (type == SJCTransitionTypeNone) {
        return nil;
    }
    
    SJCAnimationTranstion *tra = [[SJCAnimationTranstion alloc] init];
    tra.transitionType = type;
    return tra;
}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.3f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.transitionType == SJCTransitionTypePush) {
        [self pushTransitionContext:transitionContext];
    }else if (self.transitionType == SJCTransitionTypePop) {
        [self popTransitionContext:transitionContext];
    }
}

- (void)pushTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取两个VC 和 动画发生的容器
        __block SJCMediaShowController *fromVC = (SJCMediaShowController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
        __block SJCMediaBrowseController *toVC = (SJCMediaBrowseController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
        __block UIView *containerView = [transitionContext containerView];
        
        //对Cell上的 imageView 截图，同时将这个 imageView 本身隐藏
        __block SJCMediaShowCell *cell =(SJCMediaShowCell *)[fromVC.mainView cellForItemAtIndexPath:[[fromVC.mainView indexPathsForSelectedItems] firstObject]];
        fromVC.indexPath = [[fromVC.mainView indexPathsForSelectedItems] firstObject];
        
        __block CGSize size = CGSizeMake(fromVC.view.bounds.size.width, fromVC.view.bounds.size.height);
        
    @sjc_weakify(self);
    [SJCPhotoManager requestImageForAsset:cell.model.asset size:size progressHandler:nil completion:^(UIImage *image, NSDictionary *info) {
        @sjc_strongify(self);
        CGSize photosize = image.size;
//        CGSize realPhotoSize = CGSizeMake(size.width, size.width*photosize.height/photosize.width);
        
        UIView *backGroundView = [[UIView alloc]init];
        backGroundView.backgroundColor = [UIColor blackColor];
        
        UIImageView *animationImgView = [[UIImageView alloc]initWithImage:image];
        animationImgView.contentMode = UIViewContentModeScaleAspectFill;
        
        backGroundView.frame = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
        
        cell.imageView.hidden = YES;
        animationImgView.frame = [containerView convertRect:cell.imageView.frame fromView:cell.imageView.superview];
        
        CGRect photoImageViewFrame;
        CGFloat height = fromVC.view.bounds.size.height;
        
        photoImageViewFrame.size = size;//CGSizeMake(realPhotoSize.width, realPhotoSize.height ) ;
        photoImageViewFrame.origin = CGPointMake(0, 0);
        
        
        //设置第二个控制器的位置、透明度
        toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
        toVC.browseImageView.alpha = 0;
        
        
        //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
        [containerView addSubview:toVC.view];
        [containerView addSubview:backGroundView];
        [containerView addSubview:animationImgView];
        
        //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
                
                [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:
        //            [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.1f usingSpringWithDamping:0.6f initialSpringVelocity:1.0f options:UIViewAnimationOptionCurveLinear animations:
                     ^{
                        [containerView layoutIfNeeded];
                        backGroundView.frame = [containerView convertRect:CGRectMake(0, 0, toVC.view.bounds.size.width, toVC.view.bounds.size.height) fromView:toVC.view];
             //         backGroundView.frame = [containerView convertRect:CGRectMake(-10, -10, toVC.view.bounds.size.width + 20, toVC.view.bounds.size.height + 20) fromView:toVC.view];
                        
                        CGRect rect = [containerView convertRect:photoImageViewFrame fromView:toVC.view];
                        animationImgView.frame = rect;
                        
                    } completion:^(BOOL finished) {
                        //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
                        cell.imageView.hidden = NO;
                        backGroundView.backgroundColor = [UIColor clearColor];
                        toVC.browseImageView.alpha = 1.0;
                        [containerView sendSubviewToBack:backGroundView];
                        [UIView animateWithDuration:0.3 animations:^{
                            
                        } completion:^(BOOL finished) {
                            //告诉系统动画结束
                            [animationImgView removeFromSuperview];
                            [backGroundView removeFromSuperview];
                            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
                        }];
                    }];
    }];
}

- (void)popTransitionContext:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取动画前后两个VC 和 发生的容器containerView
    __block SJCMediaShowController *toVC = (SJCMediaShowController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    __block SJCMediaBrowseController *fromVC = (SJCMediaBrowseController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    __block UIView *containerView = [transitionContext containerView];
    
    SJCMediaShowCell *toCell = (SJCMediaShowCell *)[toVC targetCellForIndexPath:toVC.indexPath];
    
    UIImageView *animationImgView = [[UIImageView alloc]initWithImage:fromVC.browseImageView.image];
    animationImgView.contentMode = UIViewContentModeScaleAspectFill;
    animationImgView.clipsToBounds = YES;
    animationImgView.frame = [containerView convertRect:fromVC.browseImageView.frame fromView:fromVC.browseImageView.superview];
    fromVC.browseImageView.hidden = YES;
    
    //设置第二个控制器的位置、透明度
    toVC.view.frame = [transitionContext finalFrameForViewController:toVC];
    //把动画前后的两个ViewController加到容器中,顺序很重要,snapShotView在上方
    [containerView addSubview:toVC.view];
    [containerView addSubview:animationImgView];
    
    //动起来。第二个控制器的透明度0~1；让截图SnapShotView的位置更新到最新；
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        fromVC.view.alpha = 0.0f;
        CGRect rect = [containerView convertRect:toCell.frame fromView:toVC.mainView];
        animationImgView.frame = rect;
    } completion:^(BOOL finished) {
        //为了让回来的时候，cell上的图片显示，必须要让cell上的图片显示出来
        fromVC.browseImageView.hidden = NO;
        fromVC.view.alpha = 1.0f;
        [UIView animateWithDuration:0.3 animations:^{
            animationImgView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [animationImgView removeFromSuperview];
            //告诉系统动画结束
            [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        }];
    }];
}
@end
