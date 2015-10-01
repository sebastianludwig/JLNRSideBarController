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
{
    NSLayoutConstraint *leftBarWidthConstraint;
    NSLayoutConstraint *bottomBarHeightConstraint;
    NSLayoutConstraint *contentViewLeftConstraint;
    NSLayoutConstraint *contentViewBottomConstraint;
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.clipsToBounds = YES;
    
    self.barHidden = NO;
    
    _selectedIndex = NSNotFound;
    _maxContentWidthForBottomBar = kDefaultMaxContentWidthForBottomBar;
    _sideBarWidth = kDefaultLeftBarWidth;
    
    UIView *contentView = [UIView new];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:contentView];
    self.contentView = contentView;

    self.leftBar = [self createCollectionView];
    self.bottomBar = [self createCollectionView];
    
    [self addConstraints:@"H:|-0-[bottomBar]-0-|" toView:self];
    [self addConstraints:@"V:|-0-[leftBar]-0-|" toView:self];
    [self addConstraints:@"H:[leftBar]-0-[contentView]-0-|" toView:self];
    [self addConstraints:@"V:|-0-[contentView]-0-[bottomBar]" toView:self];
    
    leftBarWidthConstraint = [self addConstraints:@"H:[leftBar(defaultLeftBarWidth)]" toView:self.leftBar];
    bottomBarHeightConstraint = [self addConstraints:@"V:[bottomBar(defaultBottomBarHeight)]" toView:self.bottomBar];
    contentViewLeftConstraint = [self addConstraints:@"H:|-(defaultLeftBarWidth)-[contentView]" toView:self];
    contentViewBottomConstraint = [self addConstraints:@"V:[contentView]-(defaultBottomBarHeight)-|" toView:self];
}

- (NSLayoutConstraint *)addConstraints:(NSString *)visualFormat toView:(UIView *)view
{
    NSDictionary *metrics = @{ @"defaultLeftBarWidth": @(kDefaultLeftBarWidth), @"defaultBottomBarHeight": @(kDefaultBottomBarHeight) };
    NSDictionary *viewBindings = @{ @"leftBar": self.leftBar, @"bottomBar": self.bottomBar, @"contentView": self.contentView };
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:visualFormat options:0 metrics:metrics views:viewBindings];
    [view addConstraints:constraints];
    return [constraints firstObject];
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
    collectionView.translatesAutoresizingMaskIntoConstraints = NO;
    collectionView.scrollEnabled = NO;
    collectionView.dataSource = self;
    collectionView.delegate = self;
    collectionView.allowsMultipleSelection = NO;
    [collectionView registerClass:[JLNRBarCell class] forCellWithReuseIdentifier:@"Cell"];
    
    JLNRBarBackgroundView *backgroundView = [JLNRBarBackgroundView new];
    backgroundView.borderColor = self.borderColor;
    backgroundView.backgroundColor = [UIColor colorWithRed:247.f/255 green:247.f/255 blue:247.f/255 alpha:1];
    collectionView.backgroundView = backgroundView;
    collectionView.backgroundColor = [UIColor clearColor];
    
    [self addSubview:collectionView];
    
    return collectionView;
}

- (void)forEachBar:(void (^)(UICollectionView *collectionView))action
{
    for (UICollectionView *collectionView in @[self.leftBar, self.bottomBar]) {
        action(collectionView);
    }
}

- (void)updateConstraints
{
    [super updateConstraints];
    
    CGRect bounds = self.bounds;
    BOOL useLeftBar = (bounds.size.width > self.maxContentWidthForBottomBar && bounds.size.width > bounds.size.height);
    
    if (useLeftBar) {
        contentViewBottomConstraint.constant = 0;
        leftBarWidthConstraint.constant = self.sideBarWidth;
        contentViewLeftConstraint.constant = self.sideBarHidden ? 0 : leftBarWidthConstraint.constant;
        [self.leftBar.collectionViewLayout invalidateLayout];
    } else {
        contentViewBottomConstraint.constant = self.bottomBarHidden ? 0 : bottomBarHeightConstraint.constant;
        contentViewLeftConstraint.constant = 0;
        [self.bottomBar.collectionViewLayout invalidateLayout];
    }
}

- (void)updateConstraintsAnimated:(BOOL)animated
{
    __weak typeof(self)weakSelf = self;
    if (animated) {
        [self layoutIfNeeded];
        [UIView animateWithDuration:0.3
                              delay:0
                            options:(UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction)
                         animations:^{
                             [weakSelf updateConstraints];
                             [weakSelf layoutIfNeeded];
                         } completion:nil];
    } else {
        [weakSelf setNeedsUpdateConstraints];
    }
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if (selectedIndex == _selectedIndex) {
        return;
    }
    NSInteger oldIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    
    [self forEachBar:^(UICollectionView *collectionView) {
        if (oldIndex < [self collectionView:collectionView numberOfItemsInSection:0]) {
            [collectionView deselectItemAtIndexPath:[NSIndexPath indexPathForItem:oldIndex inSection:0] animated:NO];
        }
        
        NSIndexPath *selection = [NSIndexPath indexPathForItem:selectedIndex inSection:0];
        [collectionView selectItemAtIndexPath:selection animated:NO scrollPosition:UICollectionViewScrollPositionNone];
        
        if (oldIndex < [self collectionView:collectionView numberOfItemsInSection:0]) {
            [UIView performWithoutAnimation:^{
                [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:oldIndex inSection:0]]];
            }];
        }
    }];
}

- (void)setSideBarWidth:(CGFloat)sideBarWidth
{
    _sideBarWidth = sideBarWidth;
    [self setNeedsUpdateConstraints];
    [self layoutIfNeeded];
}

- (void)reloadData
{
    [self.leftBar reloadData];
    [self.bottomBar reloadData];
}

#pragma mark - Bar visibility

- (BOOL)isBarHidden
{
    return self.bottomBarHidden && self.sideBarHidden;
}

- (void)setBarHidden:(BOOL)hidden
{
    self.bottomBarHidden = hidden;
    self.sideBarHidden = hidden;
}

- (void)setBottomBarHidden:(BOOL)hidden
{
    [self setBottomBarHidden:hidden animated:NO];
}

- (void)setSideBarHidden:(BOOL)hidden
{
    [self setSideBarHidden:hidden animated:NO];
}

- (void)setBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _bottomBarHidden = hidden;
    _sideBarHidden = hidden;
    
    [self updateConstraintsAnimated:animated];
}

- (void)setBottomBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _bottomBarHidden = hidden;

    [self updateConstraintsAnimated:animated];
}

- (void)setSideBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _sideBarHidden = hidden;
    
    [self updateConstraintsAnimated:animated];
}

#pragma mark - Passing through some properties

- (void)setBorderColor:(UIColor *)borderColor
{
    _borderColor = borderColor;
    
    [self forEachBar:^(UICollectionView *collectionView) {
        JLNRBarBackgroundView *backgroundView = (JLNRBarBackgroundView *)collectionView.backgroundView;
        backgroundView.borderColor = borderColor;
    }];
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];

    [self forEachBar:^(UICollectionView *collectionView) {
        JLNRBarBackgroundView *backgroundView = (JLNRBarBackgroundView *)collectionView.backgroundView;
        
        if (backgroundColor) {
            backgroundView.backgroundColor = [UIColor clearColor];
        }
        else {
            backgroundView.backgroundColor = [UIColor colorWithRed:247.f/255 green:247.f/255 blue:247.f/255 alpha:1];
        }
    }];
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
    cell.selected = indexPath.item == self.selectedIndex;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate barView:self didSelectIndex:indexPath.item];
    self.selectedIndex = indexPath.item;
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

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [_delegate barView:self shouldSelectIndex:indexPath.item];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

@end
