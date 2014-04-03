//
//  MultiPostsTableViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewMultiPostsViewController.h"
#import "MultiPostsTableViewController.h"
#import "BigPostTableViewCell.h"
#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "KeyChainWrapper.h"

#import "Photo.h"
#import "Location.h"
#import "Institution.h"
#import "Post.h"
#import "Entity.h"
#import "Comment.h"
#import "S3RequestResponder.h"

#import "ClientManager.h"

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


// This will never get called because this table view controller is used for controlling tableview that
// is already loaded in ViewMultiPostsViewController
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

    
    
    [self.tabBarItem setTitleTextAttributes:[Utility getTabBarItemFontDictionary] forState:UIControlStateNormal];
    
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
    [self.refreshControl addTarget:self action:@selector(startRefreshingUp) forControlEvents:UIControlEventValueChanged];
    
    //hide scrollbar & clear separator
    [self.tableView setShowsVerticalScrollIndicator:NO];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
            [self startLoadingMore];
            //[self.tableView reloadData];
        }
    }
}



#pragma mark -
#pragma mark Server Communication Methods
- (void) startRefreshingUp
{

}

- (void) startLoadingMore
{
    
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
    if (![ClientManager validateCredentials]){
        NSLog(@"Abort loading photos for post %@", post.remoteID);
        return;
    }
    
    NSArray *photoKeys = [self generatePhotoKeysForPost:post withBucketName:S3BUCKET_NAME];
    
    NSManagedObjectContext *context = [RKManagedObjectStore defaultStore].mainQueueManagedObjectContext;
    NSError *error = nil;

    MSDebug(@"Number of photo to download for post %@: %d",post.remoteID, [photoKeys count]);
    
    for (NSString *photoKey in photoKeys){
        // file name is the uuid of the photo...
        NSString* uuid = [[photoKey lastPathComponent] stringByDeletingPathExtension];

        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"uuid = %@",uuid];
        
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        // there should be only unique institutions
        if (!matches || error || [matches count] > 1) {
            // handle error here
            NSLog(@"Errors in fetching photos");
//            MSDebug(@"match count %d", [matches count]);
        } else if ([matches count]) {
            // found the thing
            MSDebug(@"The photo exists! uuid = %@", uuid);
        } else {
            MSDebug(@"Photos with uuid %@ does not exist. Let's create one!", uuid);
            S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:photoKey withBucket:S3BUCKET_NAME];
            [request setContentType:@"image/png"];
            
            S3RequestResponder *delegate = [S3RequestResponder S3RequestResponderForPost:post uuid:uuid];
            
            delegate.delegate = self;
            request.delegate = delegate;
            [self.S3RequestResponders addObject:delegate];
            
            [[ClientManager s3] getObject:request];
        }
    }
    
}

#pragma mark -
#pragma mark S3 Delegate Delegate Methods
// this will remove the S3 delegate that completed its task
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
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void) followPost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    
    UIButton *followButton = (UIButton *)sender;
    bool toFollow = [[followButton titleForState:UIControlStateNormal] isEqualToString:@"follow"];

    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableURLRequest *request = nil;
    if (toFollow) {
        request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"follow_post"
                                                                         object:post
                                                                     parameters:@{@"auth_token": sessionToken}];
    
    
    } else {
        request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"unfollow_post"
                                                                         object:post
                                                                     parameters:@{@"auth_token": sessionToken}];
    }
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        [followButton setTitle:(toFollow ? @"unfollow" : @"follow")
                          forState:UIControlStateNormal];
        
        [post setFollowing:[NSNumber numberWithBool:(toFollow ? YES: NO)]];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [Utility generateAlertWithMessage:@"Failed to follow/unfollow!" error:error];
    }];
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
}

#pragma mark -
#pragma mark Table Data Source Methods
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
    
    //TODO: check if the model is empty then this will raise exception

    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    
    


//    cell.content = post.content;
    //[cell setDateToShow:[Utility getDateToShow:post.updateDate]];
    
    /*CAUTION! following is a NSNumber (though declared as bool in Core Data) 
     so you have to get its bool value
     */
    [cell.followButton setTitle:([post.following boolValue] ? @"unfollow" : @"follow")
                       forState:UIControlStateNormal];
    
    [cell.followButton addTarget:self action:@selector(followPost:)
                forControlEvents:UIControlEventTouchUpInside];
    
//    cell.dateToShow = getDateToShow(post.updateDate);
    //post.entities is a NSSet but cell.entities is a NSArray
    // actually, here we should do more work than just sending a NSArray of Entity to cell
    // because table view cell should be model-agnostic. So we pass a NSArray of NSDictionary to it
    NSMutableArray *entitiesArray = [[NSMutableArray alloc] init];
    
    [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [entitiesArray addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
    }];
    
//    cell.entities = entitiesArray;
    
    //TODO: should present all images, not just the first one
    
    UIImage *imagephoto;
    if ([post.photos count] > 0) {
        Photo *photo = [[post.photos allObjects] firstObject];
        imagephoto= [[UIImage alloc] initWithData:photo.image];
    }
    
    
    
    if ([post.photos count] > 0) {
        [cell setCellWithImage:imagephoto Entities:entitiesArray Content:post.content CommentNum:nil FollowNum:nil atDate:post.updateDate];
    }

    /*
    // We want the cell to know which row it is, so we store that in button.tag
    // However, here shareButton is depreciated
    cell.shareButton.tag = indexPath.row;
    */
    
    // Here is where we register any target of buttons in cells if the target is not the cell itself
    //[cell.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    //cell.entityButton.tag = indexPath.row;
    //[cell.entityButton addTarget:self action:@selector(entityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    [_masterController startViewingPostForPost:post];
}


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
            [_masterController sharePost];
            NSLog(@"swipeLeft at %d",indexPath.row);
        }
    }
}


#pragma mark -
#pragma mark In-cell Button Methods

-(void)entityButtonPressed:(UIButton *)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];

    // TODO: get it right! not just send the first entity of that post...
    //we don't know which one is clicked... send the first one for now
    Entity *entity = [[post.entities allObjects] firstObject];
    [_masterController startViewingEntityForEntity:entity];
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
    [self performSegueWithIdentifier:@"viewPostSegue" sender:sender];
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
        
        [nextController setPost:post];
    }
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
