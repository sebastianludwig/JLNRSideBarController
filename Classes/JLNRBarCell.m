//
//  JLNRBarCell.m
//  JLNRSideBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarCell.h"


static CGFloat const kImageViewSize = 33;
static CGFloat const kImageLabelSpacing = 2;


@interface JLNRBarCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;

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
    label.font = [UIFont systemFontOfSize:10];
    label.textColor = [self tintColor];
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
    self.label = label;
}

#pragma mark - Layout

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
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize availableSize = self.bounds.size;
    
    CGFloat spacing = (availableSize.height > availableSize.width ? kImageLabelSpacing : 0);
    
    CGRect imageViewFrame = CGRectMake(0, 0, kImageViewSize, kImageViewSize);
    [self.label sizeToFit];
    CGRect labelFrame = self.label.frame;
    
    CGFloat totalContentHeight = imageViewFrame.size.height + labelFrame.size.height + spacing;
    
    imageViewFrame.origin.x = round((availableSize.width - imageViewFrame.size.width) / 2);
    imageViewFrame.origin.y = floor((availableSize.height - totalContentHeight) / 2);
    self.imageView.frame = imageViewFrame;
    
    labelFrame.origin.x = round((availableSize.width - labelFrame.size.width) / 2);
    labelFrame.origin.y = ceil(CGRectGetMaxY(imageViewFrame)) + spacing;
    self.label.frame = labelFrame;
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
    
    self.imageView.highlighted = self.selected;
    
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
