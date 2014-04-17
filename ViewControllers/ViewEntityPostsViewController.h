//
//  ViewEntityPostsViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/17/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "MultiPostsTableViewController.h"
#import "ViewEntityViewController.h"
#import "Entity.h"

@interface ViewEntityPostsViewController : MultiPostsTableViewController

@property (strong, nonatomic) Entity *entity;
@property (weak, nonatomic) ViewEntityViewController *viewEntityViewController;

- (void)fireOff;

@end
