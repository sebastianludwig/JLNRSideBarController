//
//  JLNRBarTransitionContext.m
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 25.09.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarTransitionContext.h"

@implementation JLNRBarTransitionContext
{
    NSDictionary *viewControllers;
    NSDictionary *initialFrames;
    NSDictionary *finalFrames;
}

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController containerView:(UIView *)containerView goingRight:(BOOL)goingRight
{
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = containerView;
        viewControllers = @{
                            UITransitionContextFromViewControllerKey: fromViewController,
                            UITransitionContextToViewControllerKey: toViewController,
                            };
        
        // Set the view frame properties which make sense in our specialized ContainerViewController context. Views appear from and disappear to the sides, corresponding to where the icon buttons are positioned. So tapping a button to the right of the currently selected, makes the view disappear to the left and the new view appear from the right. The animator object can choose to use this to determine whether the transition should be going left to right, or right to left, for example.
        CGFloat travelDistance = goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width;
        
        initialFrames = @{
                          UITransitionContextFromViewControllerKey: [NSValue valueWithCGRect:self.containerView.bounds],
                          UITransitionContextToViewControllerKey: [NSValue valueWithCGRect:CGRectOffset(self.containerView.bounds, -travelDistance, 0)],
                          };
        
        finalFrames = @{
                        UITransitionContextFromViewControllerKey: [NSValue valueWithCGRect:CGRectOffset(self.containerView.bounds, travelDistance, 0)],
                        UITransitionContextToViewControllerKey: [NSValue valueWithCGRect:self.containerView.bounds],
                        };
    }
    
    return self;
}

- (NSString *)keyForViewController:(UIViewController *)viewController
{
    return viewControllers[UITransitionContextFromViewControllerKey] == viewController ? UITransitionContextFromViewControllerKey : UITransitionContextToViewControllerKey;
}

- (CGRect)initialFrameForViewController:(UIViewController *)viewController
{
    return [initialFrames[[self keyForViewController:viewController]] CGRectValue];
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController
{
    return [finalFrames[[self keyForViewController:viewController]] CGRectValue];
}

- (UIViewController *)viewControllerForKey:(NSString *)key
{
    return viewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete
{
    if (self.completionBlock) {
        self.completionBlock(didComplete);
    }
}

- (BOOL)transitionWasCancelled
{
    return NO;  // Our non-interactive transition can't be cancelled (it could be interrupted, though)
}

// Supress warnings by implementing empty interaction methods for the remainder of the protocol:

- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end