//
//  JLNRBarTransitionContext.h
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 25.09.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JLNRBarTransitionContext : NSObject<UIViewControllerContextTransitioning>

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic) UIModalPresentationStyle presentationStyle;
@property (nonatomic, getter=isAnimated) BOOL animated;
@property (nonatomic, getter=isInteractive) BOOL interactive;
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController containerView:(UIView *)containerView goingRight:(BOOL)goingRight;

@end
