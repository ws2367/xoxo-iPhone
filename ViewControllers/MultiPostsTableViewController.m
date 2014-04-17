//
//  MultiPostsTableViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "MultiPostsTableViewController.h"
#import "BigPostTableViewCell.h"
#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "MultiplePeoplePickerViewController.h"

#import "KeyChainWrapper.h"
#import "ClientManager.h"
#import "S3RequestResponder.h"

#import "Post.h"
#import "Post+MSClient.h"
#import "Entity.h"
#import "Comment.h"

#import "UIColor+MSColor.h"

// TODO: change the hard-coded number here to the height of the xib of BigPostTableViewCell
#define ROW_HEIGHT 218
#define POSTS_INCREMENT_NUM 5

// TODO: comment out depreciated codes!
@interface MultiPostsTableViewController ()



@property (strong, nonatomic) NSMutableArray *S3RequestResponders;

@end

@implementation MultiPostsTableViewController


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.title = @"Popular";
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    isLoadingMore = false;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
    //to let it cut off at tabbar edge and status bar edge
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.tableView.contentInset = UIEdgeInsetsMake(20, 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    
    //set background color
    [self.view setBackgroundColor:[UIColor colorForBackground]];
    
    
    // set up swipe gesture recognizer
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:recognizerRight];
    [self.tableView addGestureRecognizer:recognizerLeft];

    _S3RequestResponders = [[NSMutableArray alloc] init];
    
    
    // set up and fire off refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(startRefreshing) forControlEvents:UIControlEventValueChanged];
    
    //hide scrollbar & clear separator
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    MSDebug(@"Memory warning!");
}

#pragma mark -
#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentSize.height < scrollView.frame.size.height) return;
    
    if(!isLoadingMore) {
        
        CGFloat height = scrollView.frame.size.height;
        
        CGFloat contentYoffset = scrollView.contentOffset.y;
        
        CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
        
        //TODO: grab more data from server
        if(distanceFromBottom < height)
        {
            [self startLoadingMore:[self generateBasicParams]];
            //[self.tableView reloadData];
        }
    }
}



#pragma mark -
#pragma mark Server Communication Methods
//This is a wrapper for refresh control
- (void) startRefreshing{
    [self startRefreshing:[self generateBasicParams]];
}

- (NSMutableDictionary *)generateBasicParams{
    // fetch ten most popular posts ids
    //    NSArray *localPostIDs = [super fetchMostPopularPostIDsOfNumber:10 predicate:nil];
    //    NSArray *localEntityIDs = [super fetchEntityIDsOfNumber:40];
    
    
    //    MSDebug(@"post IDs to be pushed to server: %@", localPostIDs);
    //    MSDebug(@"entity IDs to be pushed to server: %@", localEntityIDs);
    
    //    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[localPostIDs, localEntityIDs, sessionToken, @"popular"]
    //                                                       forKeys:@[@"Post", @"Entity", @"auth_token", @"type"]];
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"User session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return nil;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    return [NSMutableDictionary dictionaryWithObjects:@[sessionToken, self.type]
                                              forKeys:@[@"auth_token", @"type"]];
}

- (void) startRefreshing:(NSDictionary *)params
{
    MSDebug(@"parent startRefreshing");
    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded posts from server");
                                           
                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               NSArray *posts = [mappingResult array];
                                               for (Post *post in posts) {
                                                   [self loadPhotosForPost:post];
                                               }
                                           });
                                           
                                           [self.refreshControl endRefreshing];
                                       }
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server"
                                                                               block:^{[self.refreshControl endRefreshing];}]
     ];

}

- (void) startLoadingMore:(NSMutableDictionary *)params
{
    if (isLoadingMore) return;
    else isLoadingMore = true;
    
    MSDebug(@"Start loading more");
    
    NSNumber *lastOfPreviousPostsIDs = [self fetchLastOfPreviousPostsIDsWithPredicate:self.predicate];
    if (lastOfPreviousPostsIDs == nil) return;
    
    [params setObject:lastOfPreviousPostsIDs forKey:@"last_of_previous_post_ids"];

    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded more posts from server");
                                           isLoadingMore = false;
                                           dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                               NSArray *posts = [mappingResult array];
                                               for (Post *post in posts) {
                                                   [self loadPhotosForPost:post];
                                               }
                                           });
                                       }
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server"
                                                                               block:^{isLoadingMore = false;}]
     ];
    

}

#pragma mark -
#pragma mark Client Methods


//TODO: here we can make it much more efficient by asking photos of all posts at once
- (NSArray *) generatePhotoKeysForPost:(Post *)post withBucketName:(NSString *)bucketName{
    
    if ([post.remoteID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        NSLog(@"Error in loading photos: the post is not sync'd yet.");
        return nil;
    }
        
    S3ListObjectsRequest *request = [[S3ListObjectsRequest alloc] initWithName:bucketName];
    [request setPrefix:[NSString stringWithFormat:@"%@/", post.remoteID]];
    [request setDelimiter:@"/"];
    
    S3ListObjectsResponse *response = [[ClientManager s3] listObjects:request];
    if(response.error != nil){
        NSLog(@"Error while listing photos: %@", response.error);
        return nil;
    }
    
    NSMutableArray *photoKeys = [[NSMutableArray alloc] init];
    S3ListObjectsResult *result = response.listObjectsResult;
    
    for (S3ObjectSummary *objectSummary in result.objectSummaries) {
        // object summaries might include the folder itself so we need to filter it out
        if (![[objectSummary key] hasSuffix:@"/"]) {
            [photoKeys addObject:[objectSummary key]];
        }
    }
    
    return photoKeys;
}

// let's validate AWS credentials before going further
- (void) loadPhotosForPost:(Post *)post {
    if (post.image == nil) {
        
        if (![ClientManager validateCredentials]){
            NSLog(@"Abort loading photos for post %@", post.remoteID);
            return;
        }
        
        NSArray *photoKeys = [self generatePhotoKeysForPost:post withBucketName:S3BUCKET_NAME];
        
        NSString *photoKey = [photoKeys firstObject];
        
        MSDebug(@"Photo of post %@ does not exist. Let's download it!", post.remoteID);
        MSDebug(@"Photo keypath: %@", photoKey);
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:photoKey withBucket:S3BUCKET_NAME];
        [request setContentType:@"image/png"];
        
        S3RequestResponder *delegate = [S3RequestResponder S3RequestResponderForPost:post];
        MSDebug(@"loadPhotosForPost current thread = %@", [NSThread currentThread]);
        MSDebug(@"main thread = %@", [NSThread mainThread]);
        
        delegate.delegate = self;
        request.delegate = delegate;
        [self.S3RequestResponders addObject:delegate];
        //TODO: Why does Amazon S3 Client getobject method have to run on main thead?
        // if it is not called on main thread, the delegate will not be notified. 
        dispatch_async(dispatch_get_main_queue(), ^{
            [[ClientManager s3] getObject:request];
        });
    }
}

#pragma mark -
#pragma mark S3 Delegate Delegate Methods
// this will remove the S3 delegate that completed its task
//TODO: make sure NSMutableArray removeObject is thread-safe.
- (void) removeS3RequestResponder:(id)delegate{
    [self.S3RequestResponders removeObject:(S3RequestResponder *)delegate];
}

#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}


/* Every time when a new post is created, it is first an insert at the bottom of the table view, then a move from the bottom to the top.
 * Then an update because of the context save I think.
 *
 */
- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath{
    
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView
         deleteRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        [self.tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        
        BigPostTableViewCell *cell = (BigPostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
        UIImage *imagephoto = [[UIImage alloc] initWithData:post.image];
        NSMutableArray *entitiesArray = [[NSMutableArray alloc] init];
        
        [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
            [entitiesArray addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
        }];
        [cell setCellWithImage:imagephoto Entities:entitiesArray Content:post.content CommentsCount:post.commentsCount FollowersCount:post.followersCount atDate:post.updateDate hasFollowed:[post.following boolValue]];
        
        //TODO: check if the model is empty then this will raise exception
        
//        MSDebug(@"Changed!");
//        MSDebug(@"Post content: %@", post.content);
//        MSDebug(@"Post f count: %@", post.followersCount);
//        MSDebug(@"Post c count: %@", post.commentsCount);
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark -
#pragma mark Table Data Source Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BIG_POSTS_CELL_HEIGHT;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
    id <NSFetchedResultsSectionInfo> sectionInfo = fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

// This is where cells got data and set up
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bigPostCellIdentifier];
    if (!cell){
        cell = [[BigPostTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bigPostCellIdentifier];
    }

    
    //TODO: check if the model is empty then this will raise exception

    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    
    NSMutableArray *entitiesArray = [[NSMutableArray alloc] init];
    
    [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [entitiesArray addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
    }];
    
    
    UIImage *imagephoto = [[UIImage alloc] initWithData:post.image];
    [cell setCellWithImage:imagephoto Entities:entitiesArray Content:post.content CommentsCount:post.commentsCount FollowersCount:post.followersCount atDate:post.updateDate hasFollowed:[post.following boolValue]];
    /*
    // We want the cell to know which row it is, so we store that in button.tag
    // However, here shareButton is depreciated
    cell.shareButton.tag = indexPath.row;
    */
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    /*
     CAGradientLayer *gradient = [CAGradientLayer layer];
     gradient.frame = cell.bounds;
     gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
     (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor], nil];
     [cell.layer addSublayer:gradient];
     NSLog(@"adding gradient");
     */
    
    cell.delegate = self;
    
    
    return cell;
}

#pragma mark -
#pragma mark TableView Delegate Methods
// This has to call parent controller
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    [_masterController startViewingPostForPost:post];
}*/


#pragma mark -
#pragma mark Swipe Table Cell Methods
- (void)handleSwipe:(UISwipeGestureRecognizer *)aSwipeGestureRecognizer; {
    CGPoint location = [aSwipeGestureRecognizer locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if(indexPath){
        BigPostTableViewCell * cell = (BigPostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            [cell swipeRight];
            NSLog(@"swipeRight at %d",indexPath.row);
        }
        else if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
            //[_masterController sharePost];
            NSLog(@"swipeLeft at %d",indexPath.row);
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

# pragma mark -
#pragma mark BigPostTableViewCell delegate method
- (void) CellPerformViewPost:(id)sender{
    //indicate we want to view post from top
    [sender setTag:0];
    
    [self performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)sharePost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    MultiplePeoplePickerViewController *picker = [[MultiplePeoplePickerViewController alloc] init];
    picker.delegate = self;
    [picker setSenderIndexPath:indexPath];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)commentPost:(id)sender{
    //indicate we want to comment
    [sender setTag:1];
    [self performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)followPost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [post sendFollowRequestWithFailureBlock:^{
        [Utility generateAlertWithMessage:@"Failed to follow/unfollow!" error:nil];
    }];
    
}

-(void)reportPost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to report this post?"
                                        delegate:self
                               cancelButtonTitle:@"Cancel"
                          destructiveButtonTitle:@"Report It"
                               otherButtonTitles:nil];

    [sheet setTag:indexPath.row];
    [sheet showInView:self.view];
}


# pragma mark -
#pragma mark Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewEntitySegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
        
        // TODO: get it right! not just send the first entity of that post...
        //we don't know which one is clicked... send the first one for now
        Entity *entity = [[post.entities allObjects] firstObject];

        [nextController setEntity:entity];

    } else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
        MSDebug(@"Post: %@", post);
        [nextController setPost:post];
        if ([sender tag] == 0) {
            [nextController setStartEditingComment:NO];
        }else{
            [nextController setStartEditingComment:YES];
        }

    }
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) handleNumbers:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath{
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, [selectedNumbers allObjects]]
                                                       forKeys:@[@"auth_token", @"numbers"]];
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"share_post"
                                                                                          object:post
                                                                                      parameters:params];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [Utility generateAlertWithMessage:@"Network problem" error:error];
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
    

}

- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    if ([selectedNumbers count] > 0) {
        [self handleNumbers:selectedNumbers senderIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark AlertView delegate method
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            break;
        default:
            break;
    }
    
}

#pragma mark -
#pragma mark ActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    MSDebug(@"sheet tag: %d", [actionSheet tag]);
    
    Post *post = [fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:[actionSheet tag] inSection:0]];
    
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableURLRequest *request = nil;
    request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"report_post"
                                                                     object:post
                                                                 parameters:@{@"auth_token": sessionToken}];

    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [Utility generateAlertWithMessage:@"Network problem" error:error];
    }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];

}
-(void)willPresentActionSheet:(UIActionSheet *)actionSheet{
//    [actionSheet.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        if ([obj isKindOfClass:[UIButton class]]) {
//            UIButton *button = (UIButton *)obj;
//            button.titleLabel.font = [UIFont systemFontOfSize:30];
//        }
//    }];

}

#pragma mark -
#pragma mark Miscellaneous Methods
- (NSArray *)fetchEntityIDsOfNumber:(NSInteger)number{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    // make a better guess...
    // remeber sorting booleans is possible. After all, FALSE (aka 0) comes before TRUE (aka 1)
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
    [request setFetchLimit:number];
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    if ([match count] > number) {
        NSLog(@"Fetched more than fetch limit!");
    } else if ([match count] == 0){
        // an empty array
        // do nothing
    } else {
        [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:[(Entity *)obj remoteID]];
        }];
    }
    return ids;
}

- (void) setFetchedResultsControllerWithEntityName:(NSString *)entityName
                                         predicate:(NSPredicate *)predicate
                                    sortDescriptor:(NSSortDescriptor *)sort{
    
    //set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    if (predicate) request.predicate = predicate;
    
    request.sortDescriptors = @[sort];
    
    fetchedResultsController =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:request
     managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
     sectionNameKeyPath:nil
     cacheName:nil];
    
    fetchedResultsController.delegate = self;
    
    // Let's perform one fetch here
    NSError *fetchingErr = nil;
    if ([fetchedResultsController performFetch:&fetchingErr]){
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }
    
}


- (NSArray *)fetchMostPopularPostIDsOfNumber:(NSInteger)number predicate:(NSPredicate *)predicate{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByPopularity = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO];
    NSSortDescriptor *sortByUpdateDate = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    NSSortDescriptor *sortByRemoteID = [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByPopularity, sortByUpdateDate, sortByRemoteID,nil]];
    [request setFetchLimit:number];
    if (predicate) [request setPredicate:predicate];
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    if ([match count] > number) {
        NSLog(@"Fetched more than fetch limit!");
    } else if ([match count] == 0){
        // an empty array
        // do nothing
    } else {
        [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:[(Post *)obj remoteID]];
        }];
    }
    return ids;
}

- (NSNumber *)fetchLastOfPreviousPostsIDsWithPredicate:(NSPredicate *)predicate{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByPopularity = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:YES];
    NSSortDescriptor *sortByUpdateDate = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES];
    NSSortDescriptor *sortByRemoteID = [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:NO];
    [request setFetchLimit:1];
    if (predicate) [request setPredicate:predicate];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByPopularity, sortByUpdateDate, sortByRemoteID,nil]];
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    
    if (match == nil) {
        MSError(@"error");
        return nil;
    } else if ([match count] == 0 || [match count] > 1) {
        MSError(@"error");
        return nil;
    }
    return [[match firstObject] remoteID];
}

@end
