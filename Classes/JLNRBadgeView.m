//
//  JLNRBadgeView.m
//  JLNRBarControllerExample
//
//  Created by Sebastian Ludwig on 24.09.15.
//  Copyright © 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBadgeView.h"

static CGFloat kDefaultHorizontalPadding = 4;
static CGFloat kDefaultVerticalPadding = 3;


@implementation JLNRBadgeView
{
    UILabel *_label;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setupBadgeView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder]) {
        [self setupBadgeView];
    }
    return self;
}

- (void)setupBadgeView
{
    _horizontalPadding = kDefaultHorizontalPadding;
    _verticalPadding = kDefaultVerticalPadding;
    
    _label = [[UILabel alloc] initWithFrame:self.bounds];
    _label.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:_label];
    
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    self.hidden = YES;
}

- (void)drawRect:(CGRect)rect
{
    [self.badgeColor setFill];
    [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.bounds.size.height / 2] fill];
}

- (CGSize)intrinsicContentSize
{
    CGSize labelSize = _label.intrinsicContentSize;
    CGFloat height = labelSize.height + 2 * self.verticalPadding;
    return CGSizeMake(MAX(labelSize.width + 3 * self.horizontalPadding, height), height);
}

- (NSString *)bagdeText
{
    return _label.text;
}

- (void)setBadgeText:(NSString *)badgeText
{
    _label.text = badgeText;
    self.hidden = !_label.text || _label.text.length == 0;
    [self invalidateIntrinsicContentSize];
    [self setNeedsDisplay];
}

- (void)setBadgeColor:(UIColor *)badgeColor
{
    _badgeColor = badgeColor;
    [self setNeedsDisplay];
}

- (UIColor *)textColor
{
    return _label.textColor;
}

- (void)setTextColor:(UIColor *)textColor
{
    _label.textColor = textColor;
}

- (UIFont *)font
{
    return _label.font;
}

- (void)setFont:(UIFont *)font
{
    _label.font = font;
}

@end
