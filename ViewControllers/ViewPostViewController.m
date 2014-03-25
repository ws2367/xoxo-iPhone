//
//  ViewPostViewController.m
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import "ViewMultiPostsViewController.h"
#import "CommentTableViewCell.h"
#import "KeyChainWrapper.h"

#import "Post.h"
#import "Comment.h"
#import "Photo.h"
#import "Institution.h"
#import "Location.h"

@interface ViewPostViewController ()

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSString *content;

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;

@property (weak, nonatomic) IBOutlet UILabel *entitiesLabel;
@property (strong, nonatomic) NSString *names;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic)IBOutlet UIImageView *postImage;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;

@property (strong, nonatomic) NSArray *comments; //store comment pointers
@property (strong, nonatomic) NSMutableArray *entities;
@end

#define ROW_HEIGHT 46

@implementation ViewPostViewController


- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsViewController = viewController;// Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up table view
    /*
    _tableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"CommentTableViewCell"
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    */
    // set the content
    _content = [[NSString alloc] initWithString:_post.content];
    _contentTextView.text = _content;
    
    // set entities' names
    [self setNameAndInstitionAndLocationForPost:_post];
    
    NSArray *missingInstitutionIDs = [self fetchMissingInstitutionIDsForPost:_post];
    MSDebug(@"Missing institution IDs: %@", missingInstitutionIDs);
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[missingInstitutionIDs, sessionToken]
                                                       forKeys:@[@"Institution", @"auth_token"]];
    
    // Let's ask the server for the comments of this post!
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"comments"
     ofObject:self.post
     parameters:params
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         [self setNameAndInstitionAndLocationForPost:_post];
     }
     failure:[Utility generateFailureAlertWithMessage:@"Can't connect to the server!"]];
    
    // Set debug logging level. Set to 'RKLogLevelTrace' to see JSON payload
    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    
    // set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Comment"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"post.uuid = %@", _post.uuid];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:YES];
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
        NSLog(@"Number of fetched comments %d", [[self.fetchedResultsController fetchedObjects] count]);
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }
    

    MSDebug(@"Post has comments: %@", _post.comments);
    
    //TODO: we might want to use @"photos.@count" in the predicate, check Key Value Coding and Advanced Query
    //TODO: we should show all images, not just the first one
    Photo *photo = [[self.post.photos allObjects] firstObject];
    self.postImage.image = [[UIImage alloc] initWithData:photo.image];
    
    
    // remove separators of the table view
    _tableView.separatorColor = [UIColor clearColor];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

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
}



#pragma mark -
#pragma mark Keyboard Notifification Methods
- (void) handleKeyboardWillShow:(NSNotification *)paramNotification{
    
    // get the frame of the keyboard
    NSValue *keyboardRectAsObject = [[paramNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // place it in a CGRect
    CGRect keyboardRect = CGRectZero;
    
    // I know this all looks winding and turning, keyboardRecAsObject is set type of NSValue
    // because collections like NSDictionary which is returned by [paramNotification userInfo]
    // can only store objects, not CGRect which is a C struct
    [keyboardRectAsObject getValue:&keyboardRect];
    
    // set the whole view to be right above keyboard
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame =
                         CGRectMake(self.view.frame.origin.x,
                                    keyboardRect.origin.y - self.view.frame.size.height,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}

//Oooooops. While the keyboard is moving, the super view leaks itself on the screen
//TODO: make a background view to prevent it
- (void) handleKeyboardWillHide:(NSNotification *)paramNotification{
    // let's move the view back to full screen position
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame =
                         CGRectMake(0,
                                    0,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];

}

#pragma mark -
#pragma mark Button Methods
- (IBAction)backButtonPressed:(id)sender {
    [_viewMultiPostsViewController cancelViewingPost];
}

- (IBAction)postComment:(id)sender {

    // hide the keyboard
    [_commentTextField resignFirstResponder];
    
    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                     inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];

    // This is better than [comment setValue:..... forKey:@"content"]
    // because literal string is not type-checked, but @properties are.
    comment.content = _commentTextField.text;
    comment.dirty = @YES;
    comment.uuid = [Utility getUUID];

    [comment setPost:_post];
    
    // Note that here, even if we connect the relationship to Post for the comment,
    // we still need to set postUUID in order to let the server know the relationship.
    comment.postUUID = _post.uuid;
    
    /* We want that later comments appear on the bottom of earlier comments. However, fetched results controller
     * sort comments by updateDate and updateDate is maintained by the server. Thus, we set it to the maximum locally first.
     * After receiving update_at from the server, we update updateDate accordingly. It will seem like no change on UI.
     * Moreover, when object manager post an object, it seems to save the NSManagedObject locally first so the relationship
     * is built by Core Data. Then it sends out request, maps response so the attributes such as updateDate and remoteID 
     * were updated. In the success block, I set dirty to NO and save the context again. I am sure dirt is set NO in DB.
     *
     * According to the logic above, the managed object context is saved three times.
     */
    comment.updateDate = [NSDate dateWithTimeIntervalSince1970:TIMESTAMP_MAX];
    
    
    // Let's push this to the server now!
    [[RKObjectManager sharedManager]
     postObject:comment
     path:nil
     parameters:nil
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         comment.dirty = @NO;
         
         NSError *SavingError = nil;
         // Here we are sure that remoteID, updateDate and anonymizedUserID is sent back and saved in Core Data!
         if (![comment.managedObjectContext saveToPersistentStore:&SavingError]){
          NSLog(@"Failed to save in commenting");
          NSLog(@"%@", [SavingError localizedDescription]);
          } else {
          NSLog(@"Saved Successfully in commenting");
          }
     }
     failure:[Utility generateFailureAlertWithMessage:@"Can't connect to the server!"]];
    
    // set it back to original
    [_commentTextField setTextColor:[UIColor lightGrayColor]];
    [_commentTextField setText:@"Write a comment..."];

}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
 
    // TODO: check if the model is empty then this will raise exception
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.content = comment.content;
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}


#pragma mark -
#pragma mark TextField Delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([Utility compareUIColorBetween:[textField textColor] and:[UIColor lightGrayColor]]) {
        [textField setTextColor:[UIColor blackColor]];
        [textField setText:@""];
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([[textField text] isEqualToString:@""]) {
        [textField setTextColor:[UIColor lightGrayColor]];
        [textField setText:@"Write a comment..."];
    }
}

#pragma mark -
#pragma mark Miscellaneous
- (NSArray *)fetchMissingInstitutionIDsForPost:(Post *)post{
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    for (Entity *entity in post.entities){
        if (entity.institution.uuid == nil) {
            [ids addObject:entity.institution.remoteID];
        }
    }
    return ids;
}

- (void) setNameAndInstitionAndLocationForPost:(Post *)post{
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] initWithArray:[post.entities allObjects]];
    }
    Entity *entity = [[post.entities allObjects] firstObject];
    NSMutableString *name = [NSMutableString stringWithString:entity.name];
    if (entity.institution.name)
        [name appendFormat:@", %@", entity.institution.name];
    if (entity.institution.location)
        [name appendFormat:@", %@", entity.institution.location.name];
    
    _names = name;
    MSDebug(@"%@", _names);
    [_entitiesLabel setText:_names];
    _entitiesLabel.userInteractionEnabled = YES;
    _entitiesLabel.tag = 0;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(entityClicked:)];
//    UITapGestureRecognizer *tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(entityClicked) sender:entity] autorelease];
    [_entitiesLabel addGestureRecognizer:tapGesture];

}

- (void) entityClicked:(UITapGestureRecognizer *)gr {
    UILabel *tappedLabel = (UILabel *)gr.view;
    [self performSegueWithIdentifier:@"viewEntitySegue" sender:tappedLabel];
}


# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewEntitySegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        Entity *entity = [_entities objectAtIndex:[(UILabel *)sender tag]];
        
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
