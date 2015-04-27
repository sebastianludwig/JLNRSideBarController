//
//  JLNRMenuCell.m
//  JLNRMenuController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRMenuCell.h"


static CGFloat const kImageViewSize = 33;


@interface JLNRMenuCell ()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;

@end


@implementation JLNRMenuCell

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
    
    CGRect imageViewFrame = CGRectMake(0, 0, kImageViewSize, kImageViewSize);
    [self.label sizeToFit];
    CGRect labelFrame = self.label.frame;
    
    CGFloat totalContentHeight = imageViewFrame.size.height + labelFrame.size.height;
    
    imageViewFrame.origin.x = round((availableSize.width - imageViewFrame.size.width) / 2);
    imageViewFrame.origin.y = floor((availableSize.height - totalContentHeight) / 2);
    self.imageView.frame = imageViewFrame;
    
    labelFrame.origin.x = round((availableSize.width - labelFrame.size.width) / 2);
    labelFrame.origin.y = ceil(CGRectGetMaxY(imageViewFrame));
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
    
    // We might have to update the contentView's background color.
    [self updateColors];
}

- (void)updateColors
{
    UIColor *nestedTintColor = (self.selected ? nil : [UIColor colorWithRed:92.f/255 green:92.f/255 blue:92.f/255 alpha:1]);
    
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
