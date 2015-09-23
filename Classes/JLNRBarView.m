//
//  JLNRBarView.m
//  JLNRBarController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRBarView.h"
#import "JLNRBarCell.h"
#import "JLNRBarBackgroundView.h"


static CGFloat const kDefaultLeftBarWidth = 100;
static CGFloat const kDefaultBottomBarHeight = 49;
// This happens to be "longer side of iPhone 6 Plus minus 1", i.e. by default we show the side menu on iPhone 6 Plus or an iPads in landscape.
static CGFloat const kDefaultMaxContentWidthForBottomBar = 735;

static CGFloat const kVerticalItemHeight = 66;
static CGFloat const kVerticalItemSpacing = 22;


@interface JLNRBarView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak, readwrite) UICollectionView *leftBar;
@property (nonatomic, weak, readwrite) UICollectionView *bottomBar;

@end


@implementation JLNRBarView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupBar];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupBar];
    }
    return self;
}

- (void)setupBar
{
    self.clipsToBounds = YES;
    
    _maxContentWidthForBottomBar = kDefaultMaxContentWidthForBottomBar;
    _sideBarWidth = kDefaultLeftBarWidth;
    
    self.leftBar = [self createCollectionView];
    self.bottomBar = [self createCollectionView];
    
    UIView *contentView = [UIView new];
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (UICollectionView *)createCollectionView
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    // Horizontal spacing
    layout.minimumInteritemSpacing = 0;
    // Vertical spacing
    layout.minimumLineSpacing = kVerticalItemSpacing;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.scrollEnabled = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.allowsMultipleSelection = YES;
    [collectionView registerClass:[JLNRBarCell class] forCellWithReuseIdentifier:@"Cell"];
    
    JLNRBarBackgroundView *backgroundView = [JLNRBarBackgroundView new];
    backgroundView.borderColor = self.borderColor;
    backgroundView.backgroundColor = [UIColor colorWithRed:247.f/255 green:247.f/255 blue:247.f/255 alpha:1];
    collectionView.backgroundView = backgroundView;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:collectionView];
    
    return collectionView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect bounds = self.bounds;
    BOOL useVerticalMenu = (bounds.size.width > self.maxContentWidthForBottomBar && bounds.size.width > bounds.size.height);
    
    CGRect contentFrame = bounds;
    if (useVerticalMenu) {
        contentFrame.origin.x += self.sideBarWidth;
        contentFrame.size.width -= self.sideBarWidth;
        self.contentView.frame = contentFrame;
    }
    else {
        contentFrame.size.height -= kDefaultBottomBarHeight;
        self.contentView.frame = contentFrame;
    }
    
    CGRect bottomBarFrame = bounds;
    bottomBarFrame.origin.y = bottomBarFrame.size.height;
    bottomBarFrame.size.height = kDefaultBottomBarHeight;
    if (!useVerticalMenu) {
        bottomBarFrame.origin.y -= kDefaultBottomBarHeight;
    }
    self.bottomBar.frame = bottomBarFrame;
    [self.bottomBar.collectionViewLayout invalidateLayout];
    
    CGRect leftBarFrame = bounds;
    leftBarFrame.size.width = self.sideBarWidth;
    if (!useVerticalMenu) {
        leftBarFrame.origin.y -= self.sideBarWidth;
    }
    self.leftBar.frame = leftBarFrame;
    [self.leftBar.collectionViewLayout invalidateLayout];
    
    [self sendSubviewToBack:(useVerticalMenu ? self.bottomBar : self.leftBar)];
}

- (NSInteger)selectedIndex
{
    NSIndexPath *selection = [[self.leftBar indexPathsForSelectedItems] firstObject];
    return selection.item;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    for (UICollectionView *collectionView in @[self.leftBar, self.bottomBar]) {
        while ([collectionView.indexPathsForSelectedItems count] > 0) {
            NSIndexPath *selection = [[collectionView indexPathsForSelectedItems] firstObject];     // why u no simply for loop?
            [collectionView deselectItemAtIndexPath:selection animated:NO];
        }

        NSIndexPath *selection = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
        [collectionView selectItemAtIndexPath:selection animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)reloadData
{
    [self.leftBar reloadData];
    [self.bottomBar reloadData];
}

#pragma mark - Passing through some properties

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    for (UICollectionView *collectionView in @[self.leftBar, self.bottomBar]) {
        JLNRBarBackgroundView *backgroundView = (JLNRBarBackgroundView *)collectionView.backgroundView;
        backgroundView.borderColor = borderColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    for (UICollectionView *collectionView in @[self.leftBar, self.bottomBar]) {
        JLNRBarBackgroundView *backgroundView = (JLNRBarBackgroundView *)collectionView.backgroundView;
        
        if (backgroundColor) {
            backgroundView.backgroundColor = [UIColor clearColor];
        }
        else {
            backgroundView.backgroundColor = [UIColor colorWithRed:247.f/255 green:247.f/255 blue:247.f/255 alpha:1];
        }

    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.delegate numberOfTabBarItemsForBarView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITabBarItem *tabBarItem = [self.delegate barView:self tabBarItemForIndex:indexPath.item];
    
    JLNRBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setupWithTabBarItem:tabBarItem];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.item;
    [self.delegate barView:self didSelectIndex:indexPath.item];
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger numberOfCells = [self collectionView:collectionView numberOfItemsInSection:indexPath.section];
    
    CGRect frame = collectionView.frame;
    
    if (frame.size.width > frame.size.height) {
        CGFloat width = ceil(frame.size.width / numberOfCells);
        if (indexPath.item == numberOfCells - 1) {
            width = frame.size.width - (numberOfCells - 1) * width;
        }
        return CGSizeMake(width, frame.size.height);
    }
    else {
        return CGSizeMake(frame.size.width, kVerticalItemHeight);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    NSInteger numberOfCells = [self collectionView:collectionView numberOfItemsInSection:section];
    
    CGRect frame = collectionView.frame;
    
    if (frame.size.width > frame.size.height) {
        return UIEdgeInsetsZero;
    }
    else {
        CGFloat emptySpace = frame.size.height - numberOfCells * kVerticalItemHeight - (numberOfCells - 1) * kVerticalItemSpacing;
        return UIEdgeInsetsMake(emptySpace / 2, 0, emptySpace / 2, 0);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
