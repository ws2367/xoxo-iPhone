//
//  MultiPostsTableViewController.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import "S3RequestResponder.h"

@interface MultiPostsTableViewController : UITableViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, S3RequestResponderDelegate>

@property (strong, nonatomic)ViewMultiPostsViewController *masterController;

// this will be depreciated after we use Core Data
@property (strong, nonatomic) NSMutableArray *posts;

- (void)setup;

- (void)startRefreshingUp;

- (void)startRefreshingDown;

- (void) loadPhotosForPost:(Post *)post;

- (void) deleteDelegate:(S3RequestResponder *)delegate;

- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number;

@end
