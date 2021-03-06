//
//  StylingViewController.m
//  JLNRBarControllerExample
//
//  Created by Julian Raschke on 27.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "StylingViewController.h"
#import "JLNRBarController.h"


@interface StylingViewController ()

@property (weak, nonatomic) IBOutlet UISlider *contentWidthSlider;
@property (weak, nonatomic) IBOutlet UILabel *contentWidthLabel;
@property (weak, nonatomic) IBOutlet UISlider *sideBarWidthSlider;
@property (weak, nonatomic) IBOutlet UILabel *sideBarWidthLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *backgroundControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *borderControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *selectionIndicatorControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inactiveControl;
@property (weak, nonatomic) IBOutlet UILabel *footnoteLabel;
@property (weak, nonatomic) IBOutlet UISwitch *hiddenSwitch;

@end


@implementation StylingViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGFloat contentWidth = self.jlnrBarController.barView.maxContentWidthForBottomBar;
    self.contentWidthSlider.value = contentWidth;
    self.contentWidthLabel.text = [NSString stringWithFormat:@"%@px", @(contentWidth)];
    
    
    self.sideBarWidthSlider.value = self.jlnrBarController.barView.sideBarWidth;
    self.sideBarWidthLabel.text = [NSString stringWithFormat:@"%@px", @(self.sideBarWidthSlider.value)];
    self.hiddenSwitch.on = self.jlnrBarController.isBarHidden;
    
    
    
    if ([JLNRBarView appearance].backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 2;
    }
    else if (self.jlnrBarController.barView.backgroundColor) {
        self.backgroundControl.selectedSegmentIndex = 1;
    }
    else {
        self.backgroundControl.selectedSegmentIndex = 0;
    }
    
    if ([JLNRBarView appearance].borderColor) {
        self.borderControl.selectedSegmentIndex = 2;
    }
    else if (self.jlnrBarController.barView.borderColor) {
        self.borderControl.selectedSegmentIndex = 1;
    }
    else {
        self.borderControl.selectedSegmentIndex = 0;
    }
    
    if ([[JLNRBarCell appearance] selectionIndicatorColor]) {
        self.selectionIndicatorControl.selectedSegmentIndex = 1;
    }
    else {
        self.selectionIndicatorControl.selectedSegmentIndex = 0;
    }
    
    if ([[JLNRBarCell appearance] inactiveColor]) {
        self.inactiveControl.selectedSegmentIndex = 1;
    }
    else {
        self.inactiveControl.selectedSegmentIndex = 0;
    }
}

- (IBAction)changeContentWidth:(id)sender
{
    CGFloat contentWidth = round(self.contentWidthSlider.value);
    self.jlnrBarController.barView.maxContentWidthForBottomBar = contentWidth;
    self.contentWidthLabel.text = [NSString stringWithFormat:@"%@px", @(contentWidth)];
}

- (IBAction)changeSideBarWidth
{
    CGFloat sideBarWidth = round(self.sideBarWidthSlider.value);
    self.jlnrBarController.barView.sideBarWidth = sideBarWidth;
    self.sideBarWidthLabel.text = [NSString stringWithFormat:@"%@px", @(sideBarWidth)];
}

- (IBAction)changeBackground:(id)sender
{
    BOOL custom = (self.backgroundControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.backgroundControl.selectedSegmentIndex == 2);
    
    self.jlnrBarController.barView.backgroundColor = (custom ? [UIColor purpleColor] : nil);
    [JLNRBarView appearance].backgroundColor = (appearance ? [UIColor yellowColor] : nil);
    
    if (appearance) {
        self.footnoteLabel.hidden = NO;
    }
}

- (IBAction)changeBorder:(id)sender
{
    BOOL custom = (self.borderControl.selectedSegmentIndex == 1);
    BOOL appearance = (self.borderControl.selectedSegmentIndex == 2);
    
    self.jlnrBarController.barView.borderColor = (custom ? [UIColor greenColor] : nil);
    [JLNRBarView appearance].borderColor = (appearance ? [UIColor redColor] : nil);

    if (appearance) {
        self.footnoteLabel.hidden = NO;
    }
}

- (IBAction)changeSelectionIndicator:(id)sender
{
    BOOL appearance = (self.selectionIndicatorControl.selectedSegmentIndex == 1);
    
    [JLNRBarCell appearance].selectionIndicatorColor = (appearance ? [UIColor magentaColor] : nil);
    
    self.footnoteLabel.hidden = NO;
}

- (IBAction)changeInactive:(id)sender
{
    BOOL appearance = (self.inactiveControl.selectedSegmentIndex == 1);
    
    [JLNRBarCell appearance].inactiveColor = (appearance ? [UIColor brownColor] : nil);
    
    self.footnoteLabel.hidden = NO;
}

- (IBAction)toggleHidden:(UISwitch *)sender
{
    [self.jlnrBarController setBarHidden:sender.on animated:YES];
}

- (IBAction)incrementBadgeValue
{
    int badgeValue = [self.navigationController.tabBarItem.badgeValue intValue];
    self.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%d", ++badgeValue];
}

- (IBAction)dismiss:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
