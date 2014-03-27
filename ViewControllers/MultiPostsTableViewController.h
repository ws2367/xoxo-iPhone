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

@interface MultiPostsTableViewController : UITableViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate, S3RequestResponderDelegate>{
    
    // put this variable here so that the child class can inherit it but it cannot be seen by other classes who import this class.
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic)ViewMultiPostsViewController *masterController;

- (void)setup;

- (void)startRefreshingUp;

- (void)startRefreshingDown;

- (void) loadPhotosForPost:(Post *)post;

- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number;

@end
