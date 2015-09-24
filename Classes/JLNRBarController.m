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

- (void)loadView
{
    JLNRBarView *barView = [JLNRBarView new];
    barView.delegate = self;
    self.view = barView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.barView.contentView.subviews count] == 0) {
        // Open default tab if nothing else has been shown before
        self.selectedIndex = 0;
    }
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
    if (selectedIndex < 0 || selectedIndex >= [self.viewControllers count]) {
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
    
    _viewControllers = [viewControllers copy];
    [self.barView reloadData];
    // TODO - select and show first view controller
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
