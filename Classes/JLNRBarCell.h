//
//  JLNRBarCell.h
//  JLNRSideBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface JLNRBarCell : UICollectionViewCell

@property (nonatomic) UIColor *selectionIndicatorColor UI_APPEARANCE_SELECTOR;
@property (nonatomic) UIColor *inactiveColor UI_APPEARANCE_SELECTOR;

- (void)setupWithTabBarItem:(UITabBarItem *)item;

@end
