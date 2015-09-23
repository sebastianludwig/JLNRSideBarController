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

@property (nonatomic) CGFloat barWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic) CGFloat maxContentWidthForBottomBar UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *borderColor UI_APPEARANCE_SELECTOR;

@property (nonatomic, weak, readonly) UIView *contentView;

@property (nonatomic, weak) id<JLNRBarViewDelegate> delegate;
@property (nonatomic) NSInteger selectedIndex;

- (void)reloadData;

@end


@protocol JLNRBarViewDelegate

- (NSInteger)numberOfTabBarItemsForBarView:(JLNRBarView *)barView;
- (UITabBarItem *)barView:(JLNRBarView *)barView tabBarItemForIndex:(NSInteger)index;
- (void)barView:(JLNRBarView *)barView didSelectIndex:(NSInteger)selectedIndex;

@end
