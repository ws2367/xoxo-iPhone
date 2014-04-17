//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "MultiplePeoplePickerViewController.h"
#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "NavigationController.h"
#import "CreatePostViewController.h"

#import "BigPostTableViewCell.h"
#import "CircleViewForImage.h"

#import "KeyChainWrapper.h"

#import "Entity.h"

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
    
    [_tableView setBackgroundColor:[UIColor colorForYoursWhite]];
    [self addNavigationBar];
    [self addCreatePostButton];
    [self displayNameAndInstitution];
    
    //hide scrollbar & clear separator
    [_tableView setShowsVerticalScrollIndicator:NO];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [_tableView setBackgroundColor:[UIColor colorForYoursWhite]];


}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Add bar and buttons
-(void) addNavigationBar{
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
    
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] init];
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationItem.leftBarButtonItem = homeButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
}

-(void)addCreatePostButton{
    UIImage *buttonImage = [UIImage imageNamed:@"menu-addpost.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(100, 100, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(createPostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setCenter:CGPointMake(WIDTH/2, HEIGHT - (buttonImage.size.height/2))];
    [self.view addSubview:button];
}


-(void)displayNameAndInstitution{
    NSAttributedString *name = [[NSAttributedString alloc] initWithString:[_entity name] attributes:[Utility getNavigationBarTitleFontDictionary]];
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 18, WIDTH - 40, 40)];
    [nameLabel setAttributedText:name];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    if([_entity institution]){
        NSAttributedString *insti = [[NSAttributedString alloc] initWithString:[_entity institution] attributes:[Utility getViewEntityInstitutionFontDictionary]];
        UILabel *instiLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 35, WIDTH - 40, 40)];
        [instiLabel setAttributedText:insti];
        instiLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:instiLabel];
    }
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

-(void)createPostButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"createPostSegue" sender:sender];
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


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[0];
    if (indexPath.row == sectionInfo.numberOfObjects-1 ) {
        return BIG_POSTS_CELL_HEIGHT + 40;
    }
    return BIG_POSTS_CELL_HEIGHT;
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
        [cell setCellWithImage:imagephoto Entities:entitiesArray Content:post.content CommentsCount:post.commentsCount FollowersCount:post.followersCount atDate:post.updateDate hasFollowed:[post.following boolValue]];
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
- (void) followPost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [self.fetchedResultsController  objectAtIndexPath:indexPath];
    
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
    } else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        if ([sender tag] == 0) {
            [nextController setStartEditingComment:NO];
        }else{
            [nextController setStartEditingComment:YES];
        }
        [nextController setPost:post];
    } else if ([segue.identifier isEqualToString:@"createPostSegue"]){
        CreatePostViewController *nextController = segue.destinationViewController;
        [nextController addEntity:_entity];
    }
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) handleNumbers:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath{
    Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
    
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
#pragma mark PeoplePicker Delegate Methods
/*
- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
//    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Please type in message you want to send"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Send",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
    
    return NO;
}
*/

#pragma mark -
#pragma mark alertView delegate method
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

#pragma mark UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    NSLog(@"Button %d", buttonIndex);
}
-(void)willPresentActionSheet:(UIActionSheet *)actionSheet{
    //    [actionSheet.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    //        if ([obj isKindOfClass:[UIButton class]]) {
    //            UIButton *button = (UIButton *)obj;
    //            button.titleLabel.font = [UIFont systemFontOfSize:30];
    //        }
    //    }];
    
}



@end
