//
//  ViewController.m
//  JLNRBarControllerExample
//
//  Created by Julian Raschke on 27.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "IntroViewController.h"
#import "Animator.h"


@implementation IntroViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Dev speed: save one click on each execution...
    [self performSegueWithIdentifier:@"UnstyledDemo" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnstyledDemo"]) {
        JLNRBarController *destination = segue.destinationViewController;
        destination.delegate = self;
        
        NSMutableArray *viewControllers = [NSMutableArray new];
        NSArray *colors = @[
                            [UIColor colorWithRed:0.9659 green:0.5166 blue:0.5427 alpha:1.0],
                            [UIColor colorWithRed:0.607 green:1.0 blue:0.6777 alpha:1.0],
                            [UIColor colorWithRed:0.6994 green:0.8845 blue:0.9994 alpha:1.0],
                            [UIColor colorWithRed:0.9775 green:1.0 blue:0.6052 alpha:1.0]
                            ];
        for (NSInteger i = 1; i <= 4; ++i) {
            NSString *identifier = [NSString stringWithFormat:@"Tab%@", @(i)];
            UINavigationController *navigationController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
            UIViewController *stylingViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"StylingViewController"];
            stylingViewController.view.backgroundColor = colors[i - 1];
            navigationController.viewControllers = @[stylingViewController];
            [viewControllers addObject:navigationController];
        }
        
        destination.viewControllers = viewControllers;
        destination.selectedIndex = 2;
    }
}

#pragma mark - JLNRBarControllerDelegate

- (id <UIViewControllerAnimatedTransitioning>)barController:(JLNRBarController *)barController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController
{
//    return [[Animator alloc] init];
//    return nil; // to disable animations
    return [JLNRBackdropSlideAnimator new];
}

@end
