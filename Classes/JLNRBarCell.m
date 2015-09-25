//
//  JLNRBarCell.m
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarCell.h"
#import "JLNRBadgeView.h"


static CGFloat const kImageViewSize = 33;
static CGFloat const kImageLabelHorizontalSpacing = 20;
static CGFloat const kMinimumWidthForHorizontalLayout = 200;


@interface JLNRBarCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, weak) JLNRBadgeView *badgeView;

@end


@implementation JLNRBarCell

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self createMenuCellSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self createMenuCellSubviews];
    }
    return self;
}

- (void)createMenuCellSubviews
{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    [self addSubview:imageView];
    self.imageView = imageView;
    
    UILabel *label = [[UILabel alloc] initWithFrame:self.bounds];
    label.textColor = [self tintColor];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    self.label = label;
    
    JLNRBadgeView *badgeView = [[JLNRBadgeView alloc] initWithFrame:CGRectMake(0, 0, 30, 20)];
    badgeView.badgeColor = [UIColor redColor];
    badgeView.textColor = [UIColor whiteColor];
    badgeView.horizontalPadding = 2;
    badgeView.verticalPadding = 1;
    badgeView.font = [UIFont systemFontOfSize:13];
    [self addSubview:badgeView];
    self.badgeView = badgeView;
}

#pragma mark - Layout

- (void)prepareForReuse
{
    self.selected = NO;
    self.highlighted = NO;
    self.imageView.image = nil;
    self.imageView.highlightedImage = nil;
}

- (void)setupWithTabBarItem:(UITabBarItem *)item
{
    self.imageView.image = [item.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.imageView.highlightedImage = [item.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    if (item.image.size.width > kImageViewSize || item.image.size.height > kImageViewSize) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    else {
        self.imageView.contentMode = UIViewContentModeCenter;
    }
    
    self.label.text = item.title;
    
    self.badgeView.badgeText = item.badgeValue;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize availableSize = self.bounds.size;
    
    if (availableSize.width < kMinimumWidthForHorizontalLayout) {
        // Vertical layout - mimick the system UITabBar(Item)

        CGFloat spacing = 0; //(availableSize.height > availableSize.width ? kImageLabelSpacing : 0);
        self.label.font = [UIFont systemFontOfSize:10];
        
        CGRect imageViewFrame = CGRectMake(0, 0, kImageViewSize, kImageViewSize);
        [self.label sizeToFit];
        CGRect labelFrame = self.label.frame;
        
        CGFloat totalContentHeight = imageViewFrame.size.height + labelFrame.size.height + spacing;
        
        imageViewFrame.origin.x = round((availableSize.width - imageViewFrame.size.width) / 2);
        imageViewFrame.origin.y = floor((availableSize.height - totalContentHeight) / 2);
        self.imageView.frame = imageViewFrame;
        
        labelFrame.origin.x = round((availableSize.width - labelFrame.size.width) / 2);
        labelFrame.origin.y = ceil(CGRectGetMaxY(imageViewFrame)) + spacing;
        self.label.frame = CGRectIntegral(labelFrame);
    }
    else {
        // Horizontal layout - should look more like a table-based side menu
        
        self.label.font = [UIFont boldSystemFontOfSize:14];
        
        CGRect imageViewFrame = CGRectMake(ceil(availableSize.width * 0.1), 0, kImageViewSize, kImageViewSize);
        imageViewFrame.origin.y = round((availableSize.height - kImageViewSize) / 2);
        self.imageView.frame = imageViewFrame;
        
        [self.label sizeToFit];
        CGRect labelFrame = self.label.frame;
        labelFrame.origin.x = CGRectGetMaxX(imageViewFrame) + kImageLabelHorizontalSpacing;
        labelFrame.origin.y = round((availableSize.height - labelFrame.size.height) / 2);
        self.label.frame = CGRectIntegral(labelFrame);
    }
    
    CGRect badgeFrame;
    badgeFrame.size = self.badgeView.intrinsicContentSize;
    badgeFrame.origin = CGPointMake(CGRectGetMaxX(self.imageView.frame), CGRectGetMinY(self.imageView.frame));
    badgeFrame = CGRectOffset(badgeFrame, -badgeFrame.size.width / 2 + 4, 1);
    self.badgeView.frame = CGRectIntegral(badgeFrame);
}

#pragma mark - Tint color & selection indicator color

- (void)tintColorDidChange
{
    [super tintColorDidChange];
    
    [self updateColors];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    self.imageView.highlighted = highlighted;
    
    [self updateColors];
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    self.imageView.highlighted = selected;
    
    [self updateColors];
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    // UIAppearance only applies once the view has been moved to a window, so see if we have to change the selectionIndicatorColor again.
    [self updateColors];
}

- (void)setSelectionIndicatorColor:(UIColor *)selectionIndicatorColor
{
    _selectionIndicatorColor = selectionIndicatorColor;
    
    [self updateColors];
}

- (void)setInactiveColor:(UIColor *)inactiveColor
{
    _inactiveColor = inactiveColor;
    
    [self updateColors];
}

- (void)updateColors
{
    UIColor *inactiveColor = self.inactiveColor ?: [UIColor colorWithRed:92.f/255 green:92.f/255 blue:92.f/255 alpha:1];
    UIColor *nestedTintColor = (self.selected ? nil : inactiveColor);
    
    self.imageView.tintColor = nestedTintColor;
    self.label.textColor = nestedTintColor ?: self.tintColor;
    
    if (self.selected && self.selectionIndicatorColor) {
        self.contentView.backgroundColor = self.selectionIndicatorColor;
    }
    else {
        self.contentView.backgroundColor = [UIColor clearColor];
    }
}

@end
