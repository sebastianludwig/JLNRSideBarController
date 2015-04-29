//
//  JLNRSideBarController.h
//  JLNRSideBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

// Let this header function as an umbrella header.
#import "JLNRBarCell.h"
#import "JLNRBar.h"


@interface JLNRSideBarController : UIViewController

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, weak) UIViewController *selectedViewController;
@property (nonatomic) NSInteger selectedIndex;

@property (nonatomic, readonly) JLNRBar *bar;

@end
