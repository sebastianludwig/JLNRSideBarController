//
//  UIViewController+JLNRBarController.m
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 24.09.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import "UIViewController+JLNRBarController.h"
#import "JLNRBarController.h"

@implementation UIViewController(JLNRBarController)

- (JLNRBarController *)jlnrBarController
{
    UIViewController *viewController = self;
    while (viewController) {
        if ([viewController isKindOfClass:[JLNRBarController class]]) {
            return (JLNRBarController *)viewController;
        }
        viewController = viewController.parentViewController;
    }
    return nil;
}


@end
