//
//  JLNRBadgeView.h
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 24.09.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE
@interface JLNRBadgeView : UIView

@property (copy, nonatomic) IBInspectable NSString *badgeText;
@property (nonatomic) IBInspectable UIColor *textColor;
@property (nonatomic) IBInspectable UIColor *badgeColor;

@property (nonatomic) IBInspectable UIFont *font;

@property (nonatomic) CGFloat IBInspectable horizontalPadding;
@property (nonatomic) CGFloat IBInspectable verticalPadding;

@end

