//
//  ViewEntityPostsViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/17/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewEntityPostsViewController.h"
#import "Post+MSClient.h"
#import "ClientManager.h"

@interface ViewEntityPostsViewController ()

@end

@implementation ViewEntityPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.contentInset = UIEdgeInsetsMake(6, 0, HEIGHT-self.view.bounds.size.height, 0);
    // Do any additional setup after loading the view.
}

-(void) viewDidAppear:(BOOL)animated{
    if(_postToScrollTo){
        [self scrollToPost:_postToScrollTo];
        _postToScrollTo = NULL;
    }
}

// we put stuff in fireOff method because viewDidLoad is called before the entity is set.
// Stuff in fireOff should run after the entity is set.
- (void)fireOff
{
    MSDebug(@"Entity in viewEntityPosts: %@", self.entity);
    
    // set up fetched results controller
    self.type = @"popular";
    self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.remoteID = %@", _entity.remoteID];
    
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:[self generateCompoundPredicate]
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    
    [self startRefreshing];
    [self.refreshControl beginRefreshing];

}

- (void) startRefreshing:(NSDictionary *)params
{
    MSDebug(@"View entity start refreshing");
    
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"posts"
     ofObject:self.entity
     parameters:params
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         MSDebug(@"Successfully loadded posts from server");
         
         ASYNC({
             NSArray *posts = [mappingResult array];
             [Post setIndicesAsRefreshing:posts];
             for (Post *post in posts) {
                 [ClientManager loadPhotosForPost:post];
             }
         });
         
         [self.refreshControl endRefreshing];
     }
     failure:[Utility failureBlockWithAlertMessage:@"No network connection"
                                             block:^{[self.refreshControl endRefreshing];}]];
}

- (void) startLoadingMore:(NSMutableDictionary *)params
{
    if (isLoadingMore) return;
    else isLoadingMore = true;
    
    MSDebug(@"view entity start loading more");
    
    NSNumber *lastOfPreviousPostsIDs = [self fetchLastOfPreviousPostsIDsWithPredicate:self.predicate];
    if (lastOfPreviousPostsIDs == nil) return;
    
    [params setObject:lastOfPreviousPostsIDs forKey:@"last_of_previous_post_ids"];
    
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"posts"
     ofObject:self.entity
     parameters:params
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         MSDebug(@"Successfully loadded posts from server");
         isLoadingMore = false;
         
         ASYNC({
             NSArray *posts = [mappingResult array];
             [Post setIndicesAsLoadingMore:posts];
             for (Post *post in posts) {
                 [ClientManager loadPhotosForPost:post];
             }
         });
     }
     failure:[Utility failureBlockWithAlertMessage:@"No network connection"
                                             block:^{isLoadingMore = false;}]];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark -
#pragma mark BigPostTableViewCell delegate method
-(void)setPostInViewEntityViewController:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    [_viewEntityViewController setPost:post];
}

- (void) CellPerformViewPost:(id)sender{
    //indicate we want to view post from top
    [sender setTag:0];
    [self setPostInViewEntityViewController:sender];
    
    [_viewEntityViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)commentPost:(id)sender{
    //indicate we want to comment
    [sender setTag:1];
    [self setPostInViewEntityViewController:sender];
    
    [_viewEntityViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)sharePost:(id)sender{
    [Flurry logEvent:@"Share_Post" withParameters:@{@"View":@"ViewEntity"} timed:YES];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    MultiplePeoplePickerViewController *picker = [[MultiplePeoplePickerViewController alloc] init];
    picker.delegate = self;
    [picker setSenderIndexPath:indexPath];
    [_viewEntityViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [_viewEntityViewController dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    
    if ([selectedNumbers count] > 0) {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
        [super handleNumbers:selectedNumbers senderIndexPath:indexPath];
    } else {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}

//to let the last cell taller
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = fetchedResultsController.sections[0];
    if(indexPath.row == sectionInfo.numberOfObjects - 1){
        return BIG_POSTS_CELL_HEIGHT + 40;
    } else{
        return BIG_POSTS_CELL_HEIGHT;
    }
}

-(void) scrollToPost:(Post *)post{
    NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:post];
    MSDebug(@"my index %@", indexPath);
    CGFloat offset = indexPath.row*BIG_POSTS_CELL_HEIGHT;
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:NO];
}

@end
