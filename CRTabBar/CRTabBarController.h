#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

@protocol CRTabBarControllerDelegate;

@interface CRTabBarController : UIViewController <UIGestureRecognizerDelegate>

@property (nonatomic, retain)   NSArray             *viewControllers;
@property (nonatomic, retain)   UIViewController    *selectedViewController;
@property (nonatomic, retain)   id                  <CRTabBarControllerDelegate> delegate;
@property (nonatomic, retain)   UIFont              *font;
@property (nonatomic, assign)   CGSize              maxItemSize;
@property (nonatomic, assign)   NSArray             *items;
@property (nonatomic, retain)   NSMutableArray      *itemViews;
@property (nonatomic, retain)   UIView              *tabButtonsContainerView;
@property (nonatomic, retain)   UIView              *contentContainerView;
@property (nonatomic, retain)   UIView              *shadowView;
@property (nonatomic, retain)   UIImageView         *moreItemView;
@property (nonatomic, assign)   NSUInteger          itemsPerRow;
@property (nonatomic, readonly) NSUInteger          rows;
@property (nonatomic, assign)   NSUInteger          selectedIndex;
@property (nonatomic, assign)   BOOL                moreButtonPressed;
@property (nonatomic, retain)   UIViewController    *fromController;
@property (nonatomic, retain)   UIViewController    *toController;
@property (nonatomic, retain)   NSMutableArray      *tabBarItems;
@property (nonatomic, retain)   UIGestureRecognizer *tapGesture;

- (void)hideTabBar;
- (void)showTabBar;
- (void)setSelectedIndex:(NSUInteger)newSelectedIndex animated:(BOOL)animated;
@end

/*!
 * The delegate protocol for CRTabBarController.
 */
@protocol CRTabBarControllerDelegate <NSObject>
@optional
- (BOOL)cr_tabBarController:(CRTabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
- (void)cr_tabBarController:(CRTabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController atIndex:(NSUInteger)index;
@end
