//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "BigPostTableViewCell.h"
#import "KeyChainWrapper.h"
#import "Entity.h"
#import "NavigationController.h"

#import "CircleViewForImage.h"
#import "UIColor+MSColor.h"

@interface ViewEntityViewController ()

// for map, potentially depreciated
@property (weak, nonatomic) IBOutlet UIButton *dropPinButton;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;

@property (weak, nonatomic) IBOutlet CircleViewForImage *circleViewForImage;

// entity attributes
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *institutionLabel;
@property (strong, nonatomic) NSString *institution;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSString *location;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@end

@implementation ViewEntityViewController


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
    
    // set up entity
    // TODO: make sure that Core Data makes every name attribute is filled
    [self setNameAndInstitutionAndLocation];

    //TODO: prepare post ids and entity ids too
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[sessionToken]
                                                                     forKeys:@[@"auth_token"]];
    
    
    // Let's ask the server for the posts of this entity!
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"posts"
     ofObject:self.entity
     parameters:params
     success:[Utility successBlockWithDebugMessage:@"Successfully loaded posts for the entity"
                                                     block:^{[self setNameAndInstitutionAndLocation];}]
     failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server!"]];
    
    // set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY entities.remoteID = %@", _entity.remoteID];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:NO];
    request.sortDescriptors = @[sort];
    [request setPredicate:predicate];
    
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
        MSDebug(@"Number of fetched posts %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);
        MSDebug(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch posts for entity");
    }
    
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getMultiPostsContentFontDictionary]];
    [self.view addSubview:topNavigationBar];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    [exitButton setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-popular.png"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)];
    
    [exitButton setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:[_entity name]];
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationItem.leftBarButtonItem = homeButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Navigation Bar Button Methods
- (void)exitButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)homeButtonPressed:(id)sender{
    UIViewController *thisViewController = self;
    while (![thisViewController isKindOfClass:[NavigationController class]]) {
        thisViewController = [thisViewController presentingViewController];
    }
    [thisViewController dismissViewControllerAnimated:YES completion:nil];
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
        MSDebug(@"we got an delete here! new %u, old %u",newIndexPath.row, indexPath.row);
        
        [self.tableView
         deleteRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        MSDebug(@"we got an insert here! new %u, old %u",newIndexPath.row, indexPath.row);
        
        [self.tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        MSDebug(@"we got an update here! new %u, old %u",newIndexPath.row, indexPath.row);
        
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        MSDebug(@"we got a move here! new %u, old %u",newIndexPath.row, indexPath.row);
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)sharePost{
    
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
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
    
    Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    
    
    
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
    
    

    if (post.image != nil) {
        UIImage *imagephoto = [[UIImage alloc] initWithData:post.image];
        [cell setCellWithImage:imagephoto Entities:entitiesArray Content:post.content CommentNum:nil FollowNum:nil atDate:post.updateDate];

    }
    
    /*
     // We want the cell to know which row it is, so we store that in button.tag
     // However, here shareButton is depreciated
     cell.shareButton.tag = indexPath.row;
     */
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    cell.delegate = self;
    
    
    return cell;

    

}

#pragma mark -
#pragma mark Miscellaneous Methods
- (void) setNameAndInstitutionAndLocation{
    if (_entity) {
        _name = [[NSString alloc] initWithString:_entity.name];
        _nameLabel.text = _name;
        MSDebug(@"Entity name: %@", _name);
        if (_entity.institution) {
                _institution = [[NSString alloc] initWithString:_entity.institution];
                _institutionLabel.text = _institution;
                MSDebug(@"Entity institution: %@", _institution);
        }
        if (_entity.location) {
            _location = [[NSString alloc] initWithString:_entity.location];
            _locationLabel.text = _location;
            MSDebug(@"Entity location: %@", _location);
        }
    }
}

# pragma mark -
#pragma mark BigPostTableViewCell delegate method
- (void) CellPerformViewPost:(id)sender{
    [self performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSelfSegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // TODO: get it right! not just send the first entity of that post...
        //we don't know which one is clicked... send the first one for now
        Entity *entity = [[post.entities allObjects] firstObject];
        
        [nextController setEntity:entity];
    }
    else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [nextController setPost:post];
    }
}


@end
