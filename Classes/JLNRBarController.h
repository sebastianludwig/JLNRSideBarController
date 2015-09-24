//
//  JLNRBarController.h
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

// Let this header function as an umbrella header.
#import "JLNRBarCell.h"
#import "JLNRBarView.h"
#import "UIViewController+JLNRBarController.h"


@interface JLNRBarController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, readonly) JLNRBarView *barView;

@property(nonatomic, getter=isBarHidden) BOOL barHidden;
@property(nonatomic, getter=isBottomBarHidden) BOOL bottomBarHidden;
@property(nonatomic, getter=isSideBarHidden) BOOL sideBarHidden;

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setSideBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end
