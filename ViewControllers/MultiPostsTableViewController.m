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

#import "Photo.h"
#import "Location.h"
#import "Institution.h"
#import "Post.h"
#import "Entity.h"
#import "Comment.h"

#import "AmazonClientManager.h"

// TODO: change the hard-coded number here to the height of the xib of BigPostTableViewCell
#define ROW_HEIGHT 218
#define POSTS_INCREMENT_NUM 5

// TODO: comment out depreciated codes!
@interface MultiPostsTableViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self setup];
}

- (void)setup
{
    self.posts = [[NSMutableArray alloc] init];
    
    /* old codes before storyboarding
    self.tableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                    bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];
    */
    
    // set up swipe gesture recognizer
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:recognizerRight];
    [self.tableView addGestureRecognizer:recognizerLeft];
    
    //set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:NO];
    request.sortDescriptors = @[sort];
    
    _fetchedResultsController =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:request
     managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
     sectionNameKeyPath:nil
     cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    // Let's perform one fetch here
    NSError *fetchingErr = nil;
    if ([self.fetchedResultsController performFetch:&fetchingErr]){
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }

    // set up and fire off refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(loadPosts) forControlEvents:UIControlEventValueChanged];

    // these two have to be called together or it only shows refreshing but not actually pulling any data
    [self loadPosts];
    [self.refreshControl beginRefreshing];
    
    //test
    /*
    Post *post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath ]];
     NSLog(@"before everything, post at 1 is %@", post.content);
    int i= [[self.fetchedResultsController fetchedObjects] count];
    post = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathWithIndex:(i - 1)]];
    NSLog(@"before everything, post at %d is %@", i, post.content);
     */
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark RestKit Methods
// Note that the precision of timestamp is very important. It has to be at least a float, preferably double
- (NSString *) fetchLatestTimestampOfEntityName:(NSString *)entityName{
    // get the latest updateDate
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setFetchLimit:1];
    
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSString *timestamp = nil;
    if ([match count] > 0) {
        Location *location = [match objectAtIndex:0];
        NSNumber *number = [NSNumber numberWithDouble:[location.updateDate timeIntervalSince1970]];
        timestamp = [number stringValue];
    } else {
        timestamp = [NSString stringWithFormat:@"0"];
    }
    return timestamp;
}

- (void) loadPosts{
    
    // TODO: remove fake timestamp and uncoment comments
    NSString *institutionTimestamp = [self fetchLatestTimestampOfEntityName:@"Institution"];
    NSString *entityTimestamp = @"1393987365.145751"; //[self fetchLatestTimestampOfEntityName:@"Entity"];
    NSString *postTimstamp = @"1393987368.206031"; //[self fetchLatestTimestampOfEntityName:@"Post"];
    

    void (^failureAlert)(RKObjectRequestOperation *, NSError *) = ^(RKObjectRequestOperation *operation, NSError *error){
        [self.refreshControl endRefreshing];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Can't connect to the server!"
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
        [alertView show];
    };
    
    // get objects from server
    // now this is pretty much routing-agnostic which is what we want.
    [[RKObjectManager sharedManager]
     getObject:[Location alloc] //it NSManagedObject.. not sure what will happen for allocating a NSManagedObject. Prob nothing.
     path:nil
     parameters:@{@"timestamp": @"0"}
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
         [[RKObjectManager sharedManager]
          getObject:[Institution alloc]
          path:nil
          parameters:@{@"timestamp": institutionTimestamp}
          success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
              [[RKObjectManager sharedManager]
               getObject:[Entity alloc]
               path:nil
               parameters:@{@"timestamp": entityTimestamp}
               success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                   [[RKObjectManager sharedManager]
                    getObject:[Post alloc]
                    path:nil
                    parameters:@{@"timestamp": postTimstamp}
                    success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult){
                        NSSet *posts = [mappingResult set];
                        for (Post *post in posts){
                            NSLog(@"remoteID: %@", post.remoteID);
                            [self loadPhotosForPost:post];
                        }
                        
                        [self.refreshControl endRefreshing];
                    }
                    failure:failureAlert];
                }
               failure:failureAlert];
          }
          failure:failureAlert];
     }
      failure:failureAlert];
}

#pragma mark -
#pragma mark Amazon Client Methods
// we are sure that the photo of the same uuid does not exist in core data
- (void) createPhotoEntityForPost:(Post *)post
                     andImageData:(NSData *)imageData
                          andUUID:(NSString *)uuid
           inManagedObjectContext:(NSManagedObjectContext *)context{
    Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                 inManagedObjectContext:context];
    
    // This will save NSData typed image to an external binary storage
    photo.image = imageData;
    [photo setDirty:@NO];// dirty is a NSNumber so @NO is a literal in Obj C that is created for this purpose. [NSNumber numberWithBool:] works too.
    [photo setDeleted:@NO];
    [photo setUuid:uuid];
    
    [post addPhotosObject:photo];
}


//TODO: here we can make it much more efficient by asking photos of all posts at once
- (NSArray *) generatePhotoKeysForPost:(Post *)post withBucketName:(NSString *)bucketName{
    
    if ([post.remoteID isEqualToNumber:[NSNumber numberWithInt:0]]) {
        NSLog(@"Error in loading photos: the post is not sync'd yet.");
        return nil;
    }
        
    S3ListObjectsRequest *request = [[S3ListObjectsRequest alloc] initWithName:bucketName];
    [request setPrefix:[NSString stringWithFormat:@"%@/", post.remoteID]];
    [request setDelimiter:@"/"];
    
    S3ListObjectsResponse *response = [[AmazonClientManager s3] listObjects:request];
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
            NSLog(@"photo key is %@", [photoKeys lastObject]);
        }
    }
    
    return photoKeys;
}


- (void) loadPhotosForPost:(Post *)post {
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
            MSDebug(@"match count %d", [matches count]);
        } else if ([matches count]) {
            // found the thing
            MSDebug(@"The photo exists! uuid = %@", uuid);
        } else {
            MSDebug(@"Photos with uuid %@ does not exist. Let's create one!", uuid);
            S3GetObjectRequest *request = [[S3GetObjectRequest alloc] initWithKey:photoKey withBucket:S3BUCKET_NAME];
            [request setContentType:@"image/png"];
            
            S3GetObjectResponse *response = [[AmazonClientManager s3] getObject:request];
            
            if(response.error != nil){
                NSLog(@"Error while downloading photos: %@", response.error);
            }
            
            [self createPhotoEntityForPost:post
                                 andImageData:response.body
                                   andUUID:uuid
                    inManagedObjectContext:context];
        }
        
        //let's save all the photos we just created!
        if ([context saveToPersistentStore:&error]) {
            NSLog(@"Successfully saved the photos!");
        } else {
            NSLog(@"Failed to save the managed object context.");
        }
    }
    
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
        MSDebug(@"we got an delete here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         deleteRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        MSDebug(@"we got an insert here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        MSDebug(@"we got an update here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        MSDebug(@"we got a move here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;

    //return [self.posts count];
}

// This is where cells got data and set up
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    //TODO: check if the model is empty then this will raise exception

    Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];

    cell.content = post.content;
    //post.entities is a NSSet but cell.entities is a NSArray
    // actually, here we should do more work than just sending a NSArray of Entity to cell
    // because table view cell should be model-agnostic. So we pass a NSArray of NSDictionary to it
    NSMutableArray *entitiesArray = [[NSMutableArray alloc] init];
    
    [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [entitiesArray addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
    }];
    
    cell.entities = entitiesArray;
    
    //TODO: should present all images, not just the first one
    if ([post.photos count] > 0) {
        Photo *photo = [[post.photos allObjects] firstObject];
        cell.image = [[UIImage alloc] initWithData:photo.image];
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
    
    
    return cell;
}

#pragma mark -
#pragma mark TableView Delegate Methods
// This has to call parent controller
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
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
    Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];

    // TODO: get it right! not just send the first entity of that post...
    //we don't know which one is clicked... send the first one for now
    Entity *entity = [[post.entities allObjects] firstObject];
    [_masterController startViewingEntityForEntity:entity];
}


#pragma mark -
#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    //TODO: grab more data from server
    if(distanceFromBottom < height)
    {
        //[self.tableView reloadData];
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
#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewEntitySegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // TODO: get it right! not just send the first entity of that post...
        //we don't know which one is clicked... send the first one for now
        Entity *entity = [[post.entities allObjects] firstObject];

        [nextController setEntity:entity];
    } else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [nextController setPost:post];
    }
}

@end
