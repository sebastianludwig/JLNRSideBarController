//
//  JLNRBar.h
//  JLNRSideBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JLNRBarDelegate;


@interface JLNRBar : UIView

@property (nonatomic) CGFloat menuWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maxContentWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, weak) id<JLNRBarDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (void)reloadData;

@end


@protocol JLNRBarDelegate

- (NSInteger)numberOfTabBarItemsForBar:(JLNRBar *)bar;
- (UITabBarItem *)bar:(JLNRBar *)bar tabBarItemForIndex:(NSInteger)index;
- (void)bar:(JLNRBar *)bar didSelectIndex:(NSInteger)selectedIndex;

@end
