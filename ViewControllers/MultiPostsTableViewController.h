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
#import "MultiplePeoplePickerViewController.h"
#import "BigPostTableViewCell.h"
#import <AddressBookUI/AddressBookUI.h>


@interface MultiPostsTableViewController : UITableViewController <UIScrollViewDelegate, NSFetchedResultsControllerDelegate,S3RequestResponderDelegate, BigPostTableViewCellDelegate,UIActionSheetDelegate, MultiplePeoplePickerViewControllerDelegate>{
    bool isLoadingMore;
    // put this variable here so that the child class can inherit it but it cannot be seen by other classes who import this class.
    NSFetchedResultsController *fetchedResultsController;
}

@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) NSString *type;


- (MultiplePeoplePickerViewController *)createMultiplePeoplePickerViewControllerFrom:(id)sender;
    
- (void)handleNumbers:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath;

//ViewEntityPostsViewController needs them
//- (void) loadPhotosForPost:(Post *)post;
- (NSNumber *)fetchLastOfPreviousPostsIDsWithPredicate:(NSPredicate *)predicate;


- (void)startRefreshing;

- (void) setFetchedResultsControllerWithEntityName:(NSString *)entityName
                                         predicate:(NSPredicate *)predicate
                                    sortDescriptor:(NSSortDescriptor *)sort;

//- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number;
//- (NSArray *)fetchMostPopularPostIDsOfNumber:(NSInteger)number predicate:(NSPredicate *)predicate;

@end
