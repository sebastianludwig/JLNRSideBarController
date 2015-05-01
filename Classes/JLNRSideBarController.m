//
//  JLNRSideBarController.m
//  JLNRSideBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRSideBarController.h"


@interface JLNRSideBarController () <JLNRBarDelegate>

@end


@implementation JLNRSideBarController

#pragma mark - UIViewController

- (void)loadView
{
    JLNRBar *bar = [JLNRBar new];
    bar.delegate = self;
    self.view = bar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([self.bar.contentView.subviews count] == 0) {
        // Open default tab if nothing else has been shown before
        self.selectedIndex = 0;
    }
}

#pragma mark - Interaction with the menu view

- (JLNRBar *)bar
{
    return (JLNRBar *)self.view;
}

- (NSInteger)selectedIndex
{
    return self.bar.selectedIndex;
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
    
    self.bar.selectedIndex = selectedIndex;
    
    UIViewController *newViewController = [self selectedViewController];
    [self addChildViewController:newViewController];
    newViewController.view.frame = self.bar.contentView.bounds;
    [self.bar.contentView addSubview:newViewController.view];
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
    NSAssert(index != NSNotFound, @"passing an unknown view controller to –[JLNRSideBarController setSelectedViewController:]");
    self.selectedIndex = index;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    UIViewController *oldViewController = [self selectedViewController];
    [oldViewController willMoveToParentViewController:nil];
    [oldViewController.view removeFromSuperview];
    [oldViewController removeFromParentViewController];
    
    _viewControllers = [viewControllers copy];
    [self.bar reloadData];
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

#pragma mark - JLNRBarDelegate

- (NSInteger)numberOfTabBarItemsForBar:(JLNRBar *)bar
{
    return [self.viewControllers count];
}

- (UITabBarItem *)bar:(JLNRBar *)bar tabBarItemForIndex:(NSInteger)index
{
    UIViewController *viewController = self.viewControllers[index];
    return viewController.tabBarItem;
}

- (void)bar:(JLNRBar *)bar didSelectIndex:(NSInteger)selectedIndex
{
    self.selectedIndex = selectedIndex;
}

@end
