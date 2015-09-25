//
//  JLNRBarController.m
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarController.h"


@interface JLNRBarController () <JLNRBarViewDelegate>

@end


@implementation JLNRBarController

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

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex < 0 || selectedIndex >= [self.viewControllers count] || selectedIndex == self.selectedIndex || !self.isViewLoaded) {
        return;
    }
    
    UIViewController *oldViewController = [self selectedViewController];
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    self.barView.selectedIndex = selectedIndex;
    
    UIViewController *newViewController = [self selectedViewController];
    [self addChildViewController:newViewController];
    newViewController.view.frame = self.barView.contentView.bounds;
    [self.barView.contentView addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:self];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)selectedViewController
{
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

- (void)barView:(JLNRBarView *)barView didSelectIndex:(NSInteger)selectedIndex
{
    self.selectedIndex = selectedIndex;
}

@end
