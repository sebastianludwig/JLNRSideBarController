//
//  ViewController.m
//  JLNRMenuControllerExample
//
//  Created by Julian Raschke on 27.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "IntroViewController.h"
#import "JLNRMenuController.h"


@implementation IntroViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnstyledDemo"]) {
        JLNRMenuController *destination = segue.destinationViewController;
        
        NSMutableArray *viewControllers = [NSMutableArray new];
        for (NSInteger i = 1; i <= 4; ++i) {
            NSString *identifier = [NSString stringWithFormat:@"Tab%@", @(i)];
            UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            UIViewController *dummyViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"DummyViewController"];
            navigationController.viewControllers = @[dummyViewController];
            [viewControllers addObject:navigationController];
        }
        
        destination.viewControllers = viewControllers;
    }
}

@end
