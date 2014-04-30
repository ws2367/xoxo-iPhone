//
//  MultiPostsTabBarController.h
//  Cells
//
//  Created by WYY on 2014/3/23.
//  Copyright (c) 2014年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiPostsTabBarController : UITabBarController <UITabBarControllerDelegate>
-(void)willAppearIn:(UINavigationController *)navigationController;
- (void) createPostsViewControllerWantsToSwitchAndScrollView;
@end
