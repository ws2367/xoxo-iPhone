//
//  PostsAboutMeViewController.h
//  Cells
//
//  Created by Iru on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "MultiPostsTableViewController.h"
#import "MyPostsViewController.h"

@interface PostsAboutMeViewController : MultiPostsTableViewController

@property (nonatomic, weak) MyPostsViewController *myPostsViewController;

@end
