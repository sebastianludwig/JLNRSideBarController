//
//  JLNRMenuController.m
//  JLNRMenuController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRMenuController.h"


@interface JLNRMenuController () <JLNRMenuViewDelegate>

@end


@implementation JLNRMenuController

#pragma mark - UIViewController

- (void)loadView
{
    JLNRMenuView *menuView = [JLNRMenuView new];
    menuView.delegate = self;
    self.view = menuView;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.menuView.contentView.subviews count] == 0) {
        // Open default tab if nothing else has been shown before
        self.selectedIndex = 0;
    }
}

#pragma mark - Interaction with the menu view

- (JLNRMenuView *)menuView
{
    return (JLNRMenuView *)self.view;
}

- (NSInteger)selectedIndex
{
    return self.menuView.selectedIndex;
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
    
    UIViewController *newViewController = [self selectedViewController];
    [self addChildViewController:newViewController];
    newViewController.view.frame = self.menuView.contentView.bounds;
    [self.menuView.contentView addSubview:newViewController.view];
    [newViewController didMoveToParentViewController:self];

    self.menuView.selectedIndex = selectedIndex;
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (UIViewController *)selectedViewController
{
    return self.viewControllers[self.selectedIndex];
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    UIViewController *oldViewController = [self selectedViewController];
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    _viewControllers = [viewControllers copy];
    [self.menuView reloadData];
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

- (NSUInteger)supportedInterfaceOrientations
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

#pragma mark - JLNRMenuViewDelegate

- (NSInteger)numberOfTabBarItemsForMenuView:(JLNRMenuView *)menuView
{
    return [self.viewControllers count];
}

- (UITabBarItem *)menuView:(JLNRMenuView *)menuView tabBarItemForIndex:(NSInteger)index
{
    UIViewController *viewController = self.viewControllers[index];
    return viewController.tabBarItem;
}

- (void)menuView:(JLNRMenuView *)menuView didSelectIndex:(NSInteger)selectedIndex
{
    self.selectedIndex = selectedIndex;
}

@end
