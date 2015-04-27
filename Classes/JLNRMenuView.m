//
//  JLNRMenuView.m
//  JLNRMenuController
//
//  Created by Julian Raschke on 23.04.15.
//  Copyright (c) 2015 Julian Raschke. All rights reserved.
//

#import "JLNRMenuView.h"
#import "JLNRMenuCell.h"
#import "JLNRMenuBackgroundView.h"


static CGFloat const kDefaultMenuWidth = 100;
static CGFloat const kDefaultTabBarHeight = 49;
// This happens to be (longer side of iPhone 6 Plus minus 1), i.e. by default we show the side menu on iPhone 6 Plus or an iPads in landscape.
static CGFloat const kDefaultMaxContentWidth = 735;


@interface JLNRMenuView () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak, readwrite) UICollectionView *menu;
@property (nonatomic, weak, readwrite) UICollectionView *tabBar;

@end


@implementation JLNRMenuView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setupMenuView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setupMenuView];
    }
    return self;
}

- (void)setupMenuView
{
    self.clipsToBounds = YES;
    
    _maxContentWidth = kDefaultMaxContentWidth;
    _menuWidth = kDefaultMenuWidth;
    
    self.menu = [self createCollectionView];
    self.tabBar = [self createCollectionView];
    
    UIView *contentView = [UIView new];
    [self addSubview:contentView];
    self.contentView = contentView;
}

- (UICollectionView *)createCollectionView
{
    UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    collectionView.scrollEnabled = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.allowsMultipleSelection = YES;
    [collectionView registerClass:[JLNRMenuCell class] forCellWithReuseIdentifier:@"Cell"];
    
    JLNRMenuBackgroundView *backgroundView = [JLNRMenuBackgroundView new];
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
    BOOL useVerticalMenu = (bounds.size.width > self.maxContentWidth && bounds.size.width > bounds.size.height);
    
    CGRect contentFrame = bounds;
    if (useVerticalMenu) {
        contentFrame.origin.x += self.menuWidth;
        contentFrame.size.width -= self.menuWidth;
        self.contentView.frame = contentFrame;
    }
    else {
        contentFrame.size.height -= kDefaultTabBarHeight;
        self.contentView.frame = contentFrame;
    }
    
    CGRect tabBarFrame = bounds;
    tabBarFrame.origin.y = tabBarFrame.size.height;
    tabBarFrame.size.height = kDefaultTabBarHeight;
    if (!useVerticalMenu) {
        tabBarFrame.origin.y -= kDefaultTabBarHeight;
    }
    self.tabBar.frame = tabBarFrame;
    [self.tabBar.collectionViewLayout invalidateLayout];
    
    CGRect menuFrame = bounds;
    menuFrame.size.width = self.menuWidth;
    if (!useVerticalMenu) {
        menuFrame.origin.y -= self.menuWidth;
    }
    self.menu.frame = menuFrame;
    [self.menu.collectionViewLayout invalidateLayout];
    
    [self sendSubviewToBack:(useVerticalMenu ? self.tabBar : self.menu)];
}

- (NSInteger)selectedIndex
{
    NSIndexPath *selection = [[self.menu indexPathsForSelectedItems] firstObject];
    return selection.item;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    for (UICollectionView *collectionView in @[self.menu, self.tabBar]) {
        while ([collectionView.indexPathsForSelectedItems count] > 0) {
            NSIndexPath *selection = [[collectionView indexPathsForSelectedItems] firstObject];
            [collectionView deselectItemAtIndexPath:selection animated:NO];
        }

        NSIndexPath *selection = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
        [collectionView selectItemAtIndexPath:selection animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

- (void)reloadData
{
    [self.menu reloadData];
    [self.tabBar reloadData];
}

#pragma mark - Passing through some properties

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    for (UICollectionView *collectionView in @[self.menu, self.tabBar]) {
        JLNRMenuBackgroundView *backgroundView = (JLNRMenuBackgroundView *)collectionView.backgroundView;
        backgroundView.borderColor = borderColor;
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    for (UICollectionView *collectionView in @[self.menu, self.tabBar]) {
        JLNRMenuBackgroundView *backgroundView = (JLNRMenuBackgroundView *)collectionView.backgroundView;
        
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
    return [self.delegate numberOfTabBarItemsForMenuView:self];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UITabBarItem *tabBarItem = [self.delegate menuView:self tabBarItemForIndex:indexPath.item];
    
    JLNRMenuCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    [cell setupWithTabBarItem:tabBarItem];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = indexPath.item;
    [self.delegate menuView:self didSelectIndex:indexPath.item];
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
        CGFloat height = ceil(frame.size.height / numberOfCells);
        if (indexPath.item == numberOfCells - 1) {
            height = frame.size.height - (numberOfCells - 1) * height;
        }
        return CGSizeMake(frame.size.width, height);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
