//
//  JLNRMenuController.h
//  JLNRMenuController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

// Let this header function as an umbrella header.
#import "JLNRMenuCell.h"
#import "JLNRMenuView.h"


@interface JLNRMenuController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, readonly) JLNRMenuView *menuView;

@end
