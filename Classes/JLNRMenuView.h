//
//  JLNRMenuView.h
//  JLNRMenuController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JLNRMenuViewDelegate;


@interface JLNRMenuView : UIView

@property (nonatomic) CGFloat menuWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maxContentWidth UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, weak) id<JLNRMenuViewDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (void)reloadData;

@end


@protocol JLNRMenuViewDelegate

- (NSInteger)numberOfTabBarItemsForMenuView:(JLNRMenuView *)menuView;
- (UITabBarItem *)menuView:(JLNRMenuView *)menuView tabBarItemForIndex:(NSInteger)index;
- (void)menuView:(JLNRMenuView *)menuView didSelectIndex:(NSInteger)selectedIndex;

@end
