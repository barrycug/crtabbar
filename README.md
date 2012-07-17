# CRTabBarController

This is a custom container view controller for iOS 5 that works just like a regular UITabBarController, except the tabs are at the buttom and the more button expands up instead of taking you to a new table controller.

![Screenshot](https://github.com/cmavromoustakos/crtabbar/raw/master/Screenshot.jpg)
![Screenshot](https://github.com/cmavromoustakos/crtabbar/raw/master/Screenshot2.jpg)


To use:

Declare your app delegate @interface CRTabBarAppDelegate : UIResponder <UIApplicationDelegate, CRTabBarControllerDelegate>

And setup your controllers

     UIViewController *crCategoriesslidingViewController = [[UIViewController alloc] init];
    UINavigationController *categoriesNavigationController = [[UINavigationController alloc] initWithRootViewController:crCategoriesslidingViewController];
    UITabBarItem* tabBarItem = [[UITabBarItem alloc] init];
    [tabBarItem  setFinishedSelectedImage: [UIImage imageNamed: @"ICN_home_ON"]
              withFinishedUnselectedImage: [UIImage imageNamed: @"ICN_home"]];
    [categoriesNavigationController setTabBarItem: tabBarItem];
    [viewControllers addObject:categoriesNavigationController];

The case above is a view controller wrapped in a navigation controller so we can push other views if we want to from the controller that was loaded.

The code is a compulation of 

https://github.com/hollance/MHTabBarController/

And

https://github.com/brendandixon/ExpandableTabBar


Thanks to Joe Scarano http://joescarano.com/ For the tab bar images.


The MIT License (MIT)
Copyright © 2012 Consumer Reports

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the “Software”), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
