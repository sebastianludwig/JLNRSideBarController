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

@property (weak, nonatomic) IBOutlet UISlider *contentWidthSlider;
@property (weak, nonatomic) IBOutlet UILabel *contentWidthLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *backgroundControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *borderControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectionIndicatorControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inactiveControl;
@property (weak, nonatomic) IBOutlet UILabel *footnoteLabel;

@end


@implementation StylingViewController

- (JLNRMenuController *)menuController
{
    return (JLNRMenuController *)self.navigationController.parentViewController;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat contentWidth = self.menuController.menuView.maxContentWidth;
    self.contentWidthSlider.value = contentWidth;
    self.contentWidthLabel.text = [NSString stringWithFormat:@"%@px", @(contentWidth)];
    
    if ([JLNRMenuView appearance].backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 2;
    }
    else if (self.menuController.menuView.backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 1;
    }
    else {
        self.backgroundControl.selectedSegmentIndex = 0;
    }
    
    if ([JLNRMenuView appearance].borderColor) {
        self.borderControl.selectedSegmentIndex = 2;
    }
    else if (self.menuController.menuView.borderColor) {
        self.borderControl.selectedSegmentIndex = 1;
    }
    else {
        self.borderControl.selectedSegmentIndex = 0;
    }
    
    if ([[JLNRMenuCell appearance] selectionIndicatorColor]) {
        self.selectionIndicatorControl.selectedSegmentIndex = 1;
    }
    else {
        self.selectionIndicatorControl.selectedSegmentIndex = 0;
    }
    
    if ([[JLNRMenuCell appearance] inactiveColor]) {
        self.inactiveControl.selectedSegmentIndex = 1;
    }
    else {
        self.inactiveControl.selectedSegmentIndex = 0;
    }
}

- (IBAction)changeContentWidth:(id)sender
{
    CGFloat contentWidth = round(self.contentWidthSlider.value);
    self.menuController.menuView.maxContentWidth = contentWidth;
    self.contentWidthLabel.text = [NSString stringWithFormat:@"%@px", @(contentWidth)];
}

- (IBAction)changeBackground:(id)sender
{
    BOOL custom = (self.backgroundControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.backgroundControl.selectedSegmentIndex == 2);
    
    self.menuController.menuView.backgroundColor = (custom ? [UIColor purpleColor] : nil);
    [JLNRMenuView appearance].backgroundColor = (appearance ? [UIColor yellowColor] : nil);
    
    if (appearance) {
        self.footnoteLabel.hidden = NO;
    }
}

- (IBAction)changeBorder:(id)sender
{
    BOOL custom = (self.borderControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.borderControl.selectedSegmentIndex == 2);
    
    self.menuController.menuView.borderColor = (custom ? [UIColor greenColor] : nil);
    [JLNRMenuView appearance].borderColor = (appearance ? [UIColor redColor] : nil);

    if (appearance) {
        self.footnoteLabel.hidden = NO;
    }
}

- (IBAction)changeSelectionIndicator:(id)sender
{
    BOOL appearance = (self.selectionIndicatorControl.selectedSegmentIndex == 1);
    
    [JLNRMenuCell appearance].selectionIndicatorColor = (appearance ? [UIColor magentaColor] : nil);
    
    self.footnoteLabel.hidden = NO;
}

- (IBAction)changeInactive:(id)sender
{
    BOOL appearance = (self.inactiveControl.selectedSegmentIndex == 1);
    
    [JLNRMenuCell appearance].inactiveColor = (appearance ? [UIColor brownColor] : nil);
    
    self.footnoteLabel.hidden = NO;
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
