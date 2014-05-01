//
//  MultiPostsTabBarController.h
//  Cells
//
//  Created by WYY on 2014/3/23.
//  Copyright (c) 2014年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@interface MultiPostsTabBarController : UITabBarController <UITabBarControllerDelegate>
-(void)willAppearIn:(UINavigationController *)navigationController;
- (void) createPostsViewControllerWantsToSwitchAndScrollToPost:(Post *)post;
@end
