//
//  BIDAppDelegate.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMultiPostsVC;
@class CreatePostViewController;

@interface BIDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) CreatePostViewController *viewController;
@property (strong, nonatomic) ViewMultiPostsVC *viewController;


@end
