//
//  MultiPostsTableViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultiPostsTableViewController : UITableViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic)ViewMultiPostsViewController *masterController;

// this will be depreciated after we use Core Data
@property (strong, nonatomic) NSMutableArray *posts;

- (void)setup;

- (void)startRefreshingUp;

- (void)startRefreshingDown;

- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number;

@end
