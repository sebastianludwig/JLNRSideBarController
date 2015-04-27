//
//  StylingViewController.m
//  JLNRMenuControllerExample
//
//  Created by Julian Raschke on 27.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "StylingViewController.h"
#import "JLNRMenuController.h"


@interface StylingViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *backgroundControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *borderControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectionControl;

@end


@implementation StylingViewController

- (JLNRMenuController *)menuController
{
    return (JLNRMenuController *)self.navigationController.parentViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.menuController.menuView.backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 1;
    }
    else if ([JLNRMenuView appearance].backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 2;
    }
    else {
        self.backgroundControl.selectedSegmentIndex = 0;
    }
    
    if (self.menuController.menuView.borderColor) {
        self.borderControl.selectedSegmentIndex = 1;
    }
    else if ([JLNRMenuView appearance].borderColor) {
        self.borderControl.selectedSegmentIndex = 2;
    }
    else {
        self.borderControl.selectedSegmentIndex = 0;
    }

    if ([[JLNRMenuCell appearance] selectionIndicatorColor]) {
        self.selectionControl.selectedSegmentIndex = 1;
    }
    else {
        self.selectionControl.selectedSegmentIndex = 0;
    }
}

- (IBAction)changeBackground:(id)sender
{
    BOOL custom = (self.backgroundControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.backgroundControl.selectedSegmentIndex == 2);
    
    self.menuController.menuView.backgroundColor = (custom ? [UIColor purpleColor] : nil);
    [JLNRMenuView appearance].backgroundColor = (appearance ? [UIColor redColor] : nil);
    
    [self.menuController.menuView setNeedsDisplay];
}

- (IBAction)changeBorder:(id)sender
{
    BOOL custom = (self.borderControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.borderControl.selectedSegmentIndex == 2);
    
    self.menuController.menuView.borderColor = (custom ? [UIColor greenColor] : nil);
    [JLNRMenuView appearance].borderColor = (appearance ? [UIColor magentaColor] : nil);
    
    [self.menuController.menuView setNeedsDisplay];
}

- (IBAction)changeSelection:(id)sender
{
    BOOL appearance = (self.selectionControl.selectedSegmentIndex == 1);
    
    [JLNRMenuCell appearance].selectionIndicatorColor = (appearance ? [UIColor whiteColor] : nil);
    
    [self.menuController.menuView setNeedsDisplay];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
