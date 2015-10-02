//
//  JLNRBarView.h
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol JLNRBarViewDelegate;


@interface JLNRBarView : UIView

@property (nonatomic) CGFloat sideBarWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maxContentWidthForBottomBar UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, weak) id<JLNRBarViewDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

@property(nonatomic, getter=isBarHidden) BOOL barHidden;
@property(nonatomic, getter=isBottomBarHidden) BOOL bottomBarHidden;
@property(nonatomic, getter=isSideBarHidden) BOOL sideBarHidden;

- (void)reloadData;

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated;
- (void)setSideBarHidden:(BOOL)hidden animated:(BOOL)animated;

@end


@protocol JLNRBarViewDelegate

- (NSInteger)numberOfTabBarItemsForBarView:(JLNRBarView *)barView;
- (UITabBarItem *)barView:(JLNRBarView *)barView tabBarItemForIndex:(NSInteger)index;
- (BOOL)barView:(JLNRBarView *)barView shouldSelectIndex:(NSInteger)index;
- (void)barView:(JLNRBarView *)barView willSelectIndex:(NSInteger)selectedIndex;

@end
