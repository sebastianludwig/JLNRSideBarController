//
//  JLNRBackdropSlideAnimator.m
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 01.10.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBackdropSlideAnimator.h"

@implementation JLNRBackdropSlideAnimator

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
    return 0.8;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    UIView *toView = toViewController.view;
    UIView *fromView = fromViewController.view;

    CGFloat travelDistance = [transitionContext finalFrameForViewController:fromViewController].origin.x - [transitionContext initialFrameForViewController:fromViewController].origin.x;
    CGAffineTransform scale = CGAffineTransformMakeScale(0.9, 0.9);
    CGAffineTransform translate = CGAffineTransformMakeTranslation(travelDistance, 0);
    
    [transitionContext.containerView addSubview:toView];
    toView.frame = [transitionContext initialFrameForViewController:toViewController];
    toView.transform = scale;
    
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionAllowUserInteraction animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.1 animations:^{
            fromView.transform = scale;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.2 relativeDuration:0.6 animations:^{
            fromView.transform = CGAffineTransformConcat(fromView.transform, translate);
            toView.transform = CGAffineTransformConcat(toView.transform, translate);
        }];
        [UIView addKeyframeWithRelativeStartTime:0.9 relativeDuration:0.1 animations:^{
            toView.transform = translate;
        }];
    } completion:^(BOOL finished) {       // with slow animations turned on in the Simulator, it takes ages before this is called
        fromView.transform = CGAffineTransformIdentity;
        toView.transform = CGAffineTransformIdentity;
        toView.frame = [transitionContext finalFrameForViewController:toViewController];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

@end
