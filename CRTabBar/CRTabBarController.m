

/*!
 * \file CRTabBarController.m
 *
 * Copyright (c) 2011 Matthijs Hollemans
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CRTabBarController.h"

static const float     TAB_BAR_HEIGHT    = 50.0f;
static const float     TAB_BAR_WIDTH     = 80.0f;
static const int       TABS_PER_ROW      = 4;
static const int       MORE_BUTTON_INDEX = 3;
static const int       MORE_BUTTON_TAG   = 3003;
static const CGFloat   screenHeight      = 460.0;
static const NSInteger TAG_OFFSET        = 1000;

@implementation CRTabBarController

@synthesize viewControllers         = _viewControllers;
@synthesize selectedIndex           = _selectedIndex;
@synthesize delegate                = _delegate;
@synthesize font                    = _font;
@synthesize maxItemSize             = _maxItemSize;
@synthesize items                   = _items;
@synthesize itemViews               = _itemViews;
@synthesize tabButtonsContainerView = _tabButtonsContainerView;
@synthesize contentContainerView    = _contentContainerView;
@synthesize shadowView              = _shadowView;
@synthesize moreItemView            = _moreItemView;
@synthesize itemsPerRow             = _itemsPerRow;
@synthesize rows                    = _rows;
@synthesize moreButtonPressed       = _moreButtonPressed;
@synthesize fromController          = _fromController;
@synthesize toController            = _toController;
@synthesize tabBarItems             = _tabBarItems;
@synthesize selectedViewController  = _selectedViewController;
@synthesize tapGesture              = _tapGesture;

- (void)addTabButtons
{
    self.tabBarItems = [[NSMutableArray alloc] init];
	for (UIViewController *viewController in self.viewControllers)
        [self.tabBarItems addObject: viewController.tabBarItem];
    
    [self addTabBarItems: self.tabBarItems];
}

- (UIButton *)moreTabBarButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [self setImageForMoreButton:button];
    
    button.tag = TAG_OFFSET + MORE_BUTTON_INDEX;
    
    [button addTarget:self action:@selector(moreTabButtonPressed:) forControlEvents:UIControlEventTouchDown];
    [button setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
    
    return button;
}

-(BOOL)shouldDisplayMoreButton
{
    if ([self.viewControllers count] > TABS_PER_ROW)
        return YES;
    
    return NO;
}

-(void)addTabBarItems: (NSArray *)tabBarItems
{
    NSUInteger index = 0;
    
    for (UITabBarItem *tabBarItem in tabBarItems) {
        if ([self shouldDisplayMoreButton] && index == MORE_BUTTON_INDEX)
        {
            UIButton *button = [self moreTabBarButton];
            button.tag = MORE_BUTTON_TAG;
            [self.tabButtonsContainerView addSubview:button];
        }
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage: tabBarItem.finishedUnselectedImage forState: UIControlStateNormal];
        [button setImage: tabBarItem.finishedSelectedImage forState: UIControlStateSelected];
        
        button.tag = TAG_OFFSET + index;
        
        [button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [button setContentHorizontalAlignment: UIControlContentHorizontalAlignmentCenter];
        
        [self.tabButtonsContainerView addSubview:button];
        index++;
    }
    
}

- (void)reloadTabButtons
{
    [self addTabButtons];
    [self layoutTabButtons];
    
	NSUInteger lastIndex = _selectedIndex;
	_selectedIndex = NSNotFound;
	self.selectedIndex = lastIndex;
}

- (void)layoutTabButtons
{
	NSUInteger index = 0;
    NSUInteger rowPosition = 0;
    
	CGRect rect = CGRectMake(0, 0, TAB_BAR_WIDTH, TAB_BAR_HEIGHT);
    
	NSArray *buttons = [self.tabButtonsContainerView subviews];
	for (UIButton *button in buttons)
	{
        if( (index + 1) > TABS_PER_ROW && ( (index + 1) % TABS_PER_ROW ) == 1 ) {
            ++rowPosition;
            rect.origin.x = 0;
        }
        
        rect.origin.y = rowPosition * TAB_BAR_HEIGHT;
		button.frame = rect;
		rect.origin.x += rect.size.width;
        
		++index;
	}
}

- (void)loadView
{
	[super loadView];
    
    CGRect rect = CGRectMake(0, 0, 320, screenHeight - [self tabBarHeight]);
    self.contentContainerView = [[UIView alloc] initWithFrame:rect];
    
    CGRect innerRect = CGRectMake(0, screenHeight - ([self tabBarHeight]), 320, [self tabBarHeight]);
	self.tabButtonsContainerView = [[UIView alloc] initWithFrame:innerRect];
    [self.tabButtonsContainerView setBackgroundColor: [UIColor whiteColor]];
    
    CGRect shadowRect = CGRectMake(0, screenHeight - ([self tabBarHeight]), 330, [self tabBarHeight]);
	self.shadowView = [[UIView alloc] initWithFrame: shadowRect];
    
    self.contentContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview: self.contentContainerView];
	[self.view addSubview: self.shadowView];
    [self.view addSubview: self.tabButtonsContainerView];
    
    self.shadowView.layer.masksToBounds = NO;
    self.shadowView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.shadowView.layer.shadowOffset = CGSizeMake(-10, -5);
    self.shadowView.layer.shadowRadius = 5;
    self.shadowView.layer.shadowOpacity = 0.2;
    
    self.shadowView.layer.shadowPath = [UIBezierPath bezierPathWithRect:self.shadowView.bounds].CGPath;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                          action:@selector(handleSingleTap:)];
    _tapGesture.delegate = self;
    [self.view addGestureRecognizer: _tapGesture];
    
	[self reloadTabButtons];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    UIButton *buttonTapped = (UIButton *)touch.view;
    if (buttonTapped.tag != MORE_BUTTON_TAG){
        [self.view removeGestureRecognizer: _tapGesture];
        [self collapseTabBar];
    }
    
    return NO;
}

//The event handling method
- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer
{
    // DO Nothing just a placeholder
    ;
}

- (void)viewDidUnload
{
	[super viewDidUnload];
    
    self.items = nil;
    self.font = nil;
    self.moreItemView = nil;
    self.itemViews = nil;
    self.tabBarItems = nil;
	self.tabButtonsContainerView = nil;
	self.contentContainerView = nil;
    self.fromController = nil;
    self.toController = nil;
    self.tabBarItems = nil;
}

- (void)viewWillLayoutSubviews
{
	[super viewWillLayoutSubviews];
	[self layoutTabButtons];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// Only rotate if all child view controllers agree on the new orientation.
	for (UIViewController *viewController in self.viewControllers)
	{
		if (![viewController shouldAutorotateToInterfaceOrientation:interfaceOrientation])
			return NO;
	}
	return YES;
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
	NSAssert([newViewControllers count] >= 2, @"CRTabBarController requires at least two view controllers");
    
	UIViewController *oldSelectedViewController = self.selectedViewController;
    
	// Remove the old child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[viewController willMoveToParentViewController:nil];
		[viewController removeFromParentViewController];
	}
    
	_viewControllers = [newViewControllers copy];
    
	// This follows the same rules as UITabBarController for trying to
	// re-select the previously selected view controller.
	NSUInteger newIndex = [_viewControllers indexOfObject:oldSelectedViewController];
	if (newIndex != NSNotFound)
		_selectedIndex = newIndex;
	else if (newIndex < [_viewControllers count])
		_selectedIndex = newIndex;
	else
		_selectedIndex = 0;
    
	// Add the new child view controllers.
	for (UIViewController *viewController in _viewControllers)
	{
		[self addChildViewController:viewController];
		[viewController didMoveToParentViewController:self];
	}
    
	if ([self isViewLoaded])
		[self reloadTabButtons];
}

-(void)collapseTabBar
{
    self.moreButtonPressed = NO;
    UIButton *moreButton = (UIButton *)[self.tabButtonsContainerView viewWithTag: MORE_BUTTON_TAG];
    [self setImageForMoreButton: moreButton];
    
    [self resizeTabBar];
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
{
	[self setSelectedIndex:newSelectedIndex animated:NO];
    
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex
                animated:(BOOL)animated
{
	NSAssert(newSelectedIndex < [self.viewControllers count], @"View controller index out of bounds");
    
	if ([self.delegate respondsToSelector:@selector(cr_tabBarController:shouldSelectViewController:atIndex:)])
	{
		self.toController = [self.viewControllers objectAtIndex:newSelectedIndex];
		if (![self.delegate cr_tabBarController:self shouldSelectViewController:self.toController atIndex:newSelectedIndex])
			return;
	}
    
	if (![self isViewLoaded])
	{
		_selectedIndex = newSelectedIndex;
	}
	else if (_selectedIndex != newSelectedIndex)
	{
		if (_selectedIndex != NSNotFound)
		{
			self.fromController = self.selectedViewController;
		}
        
		NSUInteger oldSelectedIndex = _selectedIndex;
		_selectedIndex = newSelectedIndex;
        
		UIButton *toButton;
		UIButton *fromButton;
		if (_selectedIndex != NSNotFound)
		{
            UITabBarItem *selectedItem = [self.tabBarItems objectAtIndex: newSelectedIndex];
            toButton = (UIButton *)[self.tabButtonsContainerView viewWithTag:TAG_OFFSET + _selectedIndex];
            [toButton setImage: selectedItem.finishedSelectedImage
                      forState: UIControlStateNormal];
            
            if (oldSelectedIndex != NSNotFound) {
                UITabBarItem *previouslySelectedItem = [self.tabBarItems objectAtIndex: oldSelectedIndex];
                
                fromButton = (UIButton *)[self.tabButtonsContainerView viewWithTag:TAG_OFFSET + oldSelectedIndex];
                [fromButton setImage: previouslySelectedItem.finishedUnselectedImage
                            forState: UIControlStateNormal];
            }
            
			self.toController = self.selectedViewController;
		}
        
		if (self.toController == nil)  // don't animate
		{
			[self.fromController.view removeFromSuperview];
		}
		else if (self.fromController == nil)  // don't animate
		{
			self.toController.view.frame = self.contentContainerView.bounds;
			[self.contentContainerView addSubview:self.toController.view];
            
			if ([self.delegate respondsToSelector:@selector(cr_tabBarController:didSelectViewController:atIndex:)])
				[self.delegate cr_tabBarController:self didSelectViewController:self.toController atIndex:newSelectedIndex];
		}
		else if (animated)
		{
			CGRect rect = self.contentContainerView.bounds;
			if (oldSelectedIndex < newSelectedIndex)
				rect.origin.x = rect.size.width;
			else
				rect.origin.x = -rect.size.width;
            
			self.toController.view.frame = rect;
			self.tabButtonsContainerView.userInteractionEnabled = NO;
            
			[self transitionFromViewController: self.fromController
                              toViewController: self.toController
                                      duration:0.3
                                       options:UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionCurveEaseOut
                                    animations:^ {
                                        CGRect rect = self.fromController.view.frame;
                                        if (oldSelectedIndex < newSelectedIndex)
                                            rect.origin.x = -rect.size.width;
                                        else
                                            rect.origin.x = rect.size.width;
                                        
                                        self.fromController.view.frame = rect;
                                        self.toController.view.frame = self.contentContainerView.bounds;
                                    }
                                    completion:^(BOOL finished)
             {
                 self.tabButtonsContainerView.userInteractionEnabled = YES;
                 
                 if ([self.delegate respondsToSelector:@selector(cr_tabBarController:didSelectViewController:atIndex:)])
                     [self.delegate cr_tabBarController:self didSelectViewController:self.toController atIndex:newSelectedIndex];
             }];
		}
		else  // not animated
		{
            
            if( self.fromController.view )
                [self.fromController.view removeFromSuperview];
            
			self.toController.view.frame = self.contentContainerView.bounds;
			[self.contentContainerView addSubview:self.toController.view];
            
			if ([self.delegate respondsToSelector:@selector(cr_tabBarController:didSelectViewController:atIndex:)])
				[self.delegate cr_tabBarController:self didSelectViewController:self.toController atIndex:newSelectedIndex];
		}
	}
    self.moreButtonPressed = NO;
    [self collapseTabBar];
}

- (UIViewController *)selectedViewController
{
	if (self.selectedIndex != NSNotFound)
		return [self.viewControllers objectAtIndex:self.selectedIndex];
	else
		return nil;
}

- (void)tabButtonPressed:(UIButton *)sender
{
	[self setSelectedIndex:sender.tag - TAG_OFFSET animated:YES];
}

- (NSUInteger)indexForViewController:(UIViewController *)newSelectedViewController
{
	NSUInteger index = [self.viewControllers indexOfObject:newSelectedViewController];
    return index;
}

- (void)moreTabButtonPressed:(UIButton *)sender
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    self.moreButtonPressed = !self.moreButtonPressed;
    
    if (self.moreButtonPressed) {
        [self.view addGestureRecognizer: _tapGesture];
    }
    [self setImageForMoreButton:sender];
    [self resizeTabBar];
    [UIView commitAnimations];
}

-(void)setImageForMoreButton: (UIButton *)moreButton
{
    if (self.selectedIndex >= MORE_BUTTON_INDEX) {
        [moreButton setImage: [UIImage imageNamed:@"ICN_more_on"] forState: UIControlStateNormal];
        return;
    }
    
    if(!self.moreButtonPressed) {
        [moreButton setImage: [UIImage imageNamed:@"ICN_more"] forState: UIControlStateNormal];
        [moreButton setImage: [UIImage imageNamed:@"ICN_more_ON"] forState: UIControlStateSelected];
    } else {
        [moreButton setImage: [UIImage imageNamed:@"ICN_less_ON"] forState: UIControlStateNormal];
        [moreButton setImage: [UIImage imageNamed:@"ICN_less_ON"] forState: UIControlStateSelected];
    }
}

-(void)hideTabBar {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [self.contentContainerView setFrame:CGRectMake(self.contentContainerView.frame.origin.x,
                                                   0,
                                                   self.contentContainerView.frame.size.width,
                                                   480)];
    
    [self.tabButtonsContainerView setFrame:CGRectMake(self.tabButtonsContainerView.frame.origin.x,
                                                      480,
                                                      self.tabButtonsContainerView.frame.size.width,
                                                      self.tabButtonsContainerView.frame.size.height)];
    
    [self.shadowView setFrame:CGRectMake(self.shadowView.frame.origin.x,
                                         480,
                                         self.shadowView.frame.size.width,
                                         self.shadowView.frame.size.height)];
    
    [UIView commitAnimations];
}

-(void)showTabBar {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.5];
    
    [self resizeTabBar];
    [UIView commitAnimations];
}

-(void)resizeTabBar
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    
    CGRect rect = CGRectMake(0, 0, 320, screenHeight - [self tabBarHeight]);
    CGRect innerRect = CGRectMake(0, screenHeight - [self tabBarHeight], 320, [self tabBarHeight]);
    
    self.contentContainerView.frame = rect;
	self.tabButtonsContainerView.frame = innerRect;    
	self.shadowView.frame = innerRect;
    [UIView commitAnimations];
}

# pragma mark - Geometry

-(CGFloat)tabBarHeight
{    
    if (self.moreButtonPressed) {
        return TAB_BAR_HEIGHT * [self tabBarRows];
    }
    else {
        return TAB_BAR_HEIGHT;
    }
}

-(NSUInteger)tabBarRows
{
    NSUInteger extraRow = 0;
    
    if (([self.viewControllers count] % 4) > 0) {
        extraRow = 1;
    }
    
    NSInteger tabCounter = ([self.viewControllers count] / 4) + extraRow;
    return tabCounter;
}

@end
