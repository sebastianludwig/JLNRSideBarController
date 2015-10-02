//
//  JLNRBarController.m
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarController.h"
#import "JLNRBarTransitionContext.h"


@interface JLNRBarController () <JLNRBarViewDelegate>

@end


@implementation JLNRBarController
{
    BOOL _transitionInProgress;
}

#pragma mark - UIViewController

- (void)dealloc
{
    [self removeObserverFromViewControllers];
}

- (void)loadView
{
    JLNRBarView *barView = [JLNRBarView new];
    barView.delegate = self;
    self.view = barView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (![self tabHasEverBeenSelected]) {
        // Open default tab if nothing else has been shown before
        self.selectedIndex = 0;
    }
}

#pragma mark - JLNRBarController

- (BOOL)tabHasEverBeenSelected
{
    return [self.barView.contentView.subviews count] > 0;   // HINT: this coupling is pretty tight (insider info of JLNRBarView workings)
}

#pragma mark - KVO

- (void)removeObserverFromViewControllers
{
    for (UIViewController *viewController in self.viewControllers) {
        [viewController removeObserver:self forKeyPath:@"tabBarItem.badgeValue"];
    }
}

- (void)addObserverToViewControllers
{
    for (UIViewController *viewController in self.viewControllers) {
        [viewController addObserver:self forKeyPath:@"tabBarItem.badgeValue" options:0 context:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.barView reloadData];
}

#pragma mark - Bar visibility

- (BOOL)isBarHidden
{
    return self.barView.isBarHidden;
}

- (BOOL)isBottomBarHidden
{
    return self.barView.isBottomBarHidden;
}

- (BOOL)isSideBarHidden
{
    return self.barView.isSideBarHidden;
}

- (void)setBarHidden:(BOOL)hidden
{
    self.barView.barHidden = hidden;
}

- (void)setBottomBarHidden:(BOOL)hidden
{
    self.barView.bottomBarHidden = hidden;
}

- (void)setSideBarHidden:(BOOL)hidden
{
    self.barView.sideBarHidden = hidden;
}

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [self.barView setBarHidden:hidden animated:animated];
}

- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self.barView setBottomBarHidden:hidden animated:animated];
}

- (void)setSideBarHidden:(BOOL)hidden animated:(BOOL)animated
{
	[self.barView setSideBarHidden:hidden animated:animated];
}

#pragma mark - Interaction with the bar view

- (JLNRBarView *)barView
{
    return (JLNRBarView *)self.view;
}

- (NSInteger)selectedIndex
{
    return self.barView.selectedIndex;
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight
{
    _transitionInProgress = YES;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    toViewController.view.translatesAutoresizingMaskIntoConstraints = YES;
    toViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    toViewController.view.frame = self.barView.contentView.bounds;
    
    if (![self tabHasEverBeenSelected]) {
        [self.barView.contentView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        _transitionInProgress = NO;
        return;
    }
    
    
    
    id<UIViewControllerAnimatedTransitioning> animator;
    if ([self.delegate respondsToSelector:@selector(barController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.delegate barController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    
    void (^transitionCompletion)(BOOL) = ^void(BOOL didComplete) {
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        
        [toViewController didMoveToParentViewController:self];
        
        [self setNeedsStatusBarAppearanceUpdate];
        
        if ([animator respondsToSelector:@selector(animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        _transitionInProgress = NO;
    };
    
    
    if (animator) {
        JLNRBarTransitionContext *transitionContext = [[JLNRBarTransitionContext alloc] initWithFromViewController:fromViewController
                                                                                                  toViewController:toViewController
                                                                                                     containerView:self.barView.contentView
                                                                                                        goingRight:goingRight];
        transitionContext.animated = YES;
        transitionContext.interactive = NO;
        transitionContext.completionBlock = transitionCompletion;
        
        
        [animator animateTransition:transitionContext];
    } else {
        [self.barView.contentView addSubview:toViewController.view];
        transitionCompletion(YES);
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex < 0 || selectedIndex >= self.viewControllers.count || (selectedIndex == self.selectedIndex && [self tabHasEverBeenSelected]) || !self.isViewLoaded) {
        return;
    }
    
    if (_transitionInProgress) {
        return;
    }
    
    BOOL goingRight = selectedIndex > self.selectedIndex;
    
    UIViewController *oldViewController = [self selectedViewController];
    self.barView.selectedIndex = selectedIndex;
    UIViewController *newViewController = [self selectedViewController];
    
    [self transitionFromViewController:oldViewController toViewController:newViewController goingRight:goingRight];
    
    if ([self.delegate respondsToSelector:@selector(barController:didSelectViewController:)]) {
        [self.delegate barController:self didSelectViewController:newViewController];
    }
}

- (UIViewController *)selectedViewController
{
    if (self.selectedIndex < 0 || self.selectedIndex > self.viewControllers.count) {
        return nil;
    }
    return self.viewControllers[self.selectedIndex];
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    NSInteger index = [self.viewControllers indexOfObject:selectedViewController];
    NSAssert(index != NSNotFound, @"passing an unknown view controller to %s", __PRETTY_FUNCTION__);
    self.selectedIndex = index;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    UIViewController *oldViewController = [self selectedViewController];
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    [self removeObserverFromViewControllers];
    
    _viewControllers = [viewControllers copy];
    
    [self addObserverToViewControllers];
    
    [self.barView reloadData];
    
    // reselection like UITabViewController does it
    if ([self tabHasEverBeenSelected]) {
        NSInteger index = [self.viewControllers indexOfObject:oldViewController];
        if (index != NSNotFound) {
            self.selectedIndex = index;
        } else if (self.selectedIndex < _viewControllers.count) {
            self.selectedIndex = self.selectedIndex; // reselect
        } else {
            self.selectedIndex = 0;
        }
    }
}

#pragma mark - Message forwarding to nested view controllers

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return self.selectedViewController.preferredStatusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return self.selectedViewController.preferredStatusBarUpdateAnimation;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    UIInterfaceOrientationMask mask = UIInterfaceOrientationMaskAll;
    
    for (UIViewController *viewController in self.viewControllers) {
        if ([viewController respondsToSelector:@selector(supportedInterfaceOrientations)]) {
            mask &= [viewController supportedInterfaceOrientations];
        }
    }
    
    return mask;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    for (UIViewController *viewController in self.viewControllers) {
        if (![viewController respondsToSelector:@selector(shouldAutorotateToInterfaceOrientation:)] ||
            ![viewController shouldAutorotateToInterfaceOrientation:toInterfaceOrientation]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - JLNRBarDelegate

- (NSInteger)numberOfTabBarItemsForBarView:(JLNRBarView *)barView
{
    return [self.viewControllers count];
}

- (UITabBarItem *)barView:(JLNRBarView *)barView tabBarItemForIndex:(NSInteger)index
{
    UIViewController *viewController = self.viewControllers[index];
    return viewController.tabBarItem;
}

- (BOOL)barView:(JLNRBarView *)barView shouldSelectIndex:(NSInteger)index
{
    return !_transitionInProgress;
}

- (void)barView:(JLNRBarView *)barView willSelectIndex:(NSInteger)selectedIndex
{
    self.selectedIndex = selectedIndex;
}

@end
