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
    bool isLoadingMore;
    // put this variable here so that the child class can inherit it but it cannot be seen by other classes who import this class.
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic)ViewMultiPostsViewController *masterController;

- (void)startRefreshingUp;

- (void)startLoadingMore;

- (void) loadPhotosForPost:(Post *)post;

- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number;

- (NSNumber *)fetchLastOfPreviousPostsIDsWithPredicate:(NSPredicate *)predicate;

- (void) setFetchedResultsControllerWithEntityName:(NSString *)entityName
                                         predicate:(NSPredicate *)predicate
                                    sortDescriptor:(NSSortDescriptor *)sort;

- (NSArray *)fetchMostPopularPostIDsOfNumber:(NSInteger)number predicate:(NSPredicate *)predicate;

@end
