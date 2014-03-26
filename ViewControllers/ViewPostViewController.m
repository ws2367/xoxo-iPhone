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
@property (strong, nonatomic) NSString *names;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic)IBOutlet UIImageView *postImage;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;

@property (strong, nonatomic) NSArray *comments; //store comment pointers
@property (strong, nonatomic) NSMutableArray *entities;
@end

#define ROW_HEIGHT 46
#define START_ENTITIES_Y 220
#define ENTITY_HEIGHT 25
#define LEFT_OFFSET 5

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
//    _content = [[NSString alloc] initWithString:_post.content];
//    _contentTextView.text = _content;
    
    // set entities' names
    [self setAllContentForPost:_post];
    
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
     success:[Utility successBlockWithDebugMessage:@"Successfully pulled comments for the post!"
                                                     block:^{[self setAllContentForPost:_post];}]
     failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server!"]];
    
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
    else if (type == NSFetchedResultsChangeUpdate) {
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
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
                        options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame =
                         CGRectMake(self.view.frame.origin.x,
                                    keyboardRect.origin.y - HEIGHT,
                                    WIDTH,
                                    HEIGHT);
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
                        options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame =
                         CGRectMake(0,
                                    0,
                                    WIDTH,
                                    HEIGHT);
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
    comment.dirty = @NO; //TODO: kill diry field when its ready to die
    comment.uuid = [Utility getUUID];
    comment.isYours = @YES;
    [comment setPost:_post];
    
    // Note that here, even if we connect the relationship to Post for the comment,
    // we still need to set postUUID in order to let the server know the relationship.
    //TODO: change to using remoteID instead of uuid
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
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"At ViewPostViewController: user session token is not valid. Stop posting the comment.");
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken]
                                                       forKeys:@[@"auth_token"]];

    MSDebug(@"The comment to be posted: %@", comment);
    // Let's push this to the server now!
    [[RKObjectManager sharedManager]
     postObject:comment
     path:nil
     parameters:params
     success:[Utility successBlockWithDebugMessage:@"Succcessfully posted the comment" block:nil]
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext deleteObject:comment];
         
         [Utility generateAlertWithMessage:@"No network!" error:nil];
     }];
    
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
    [cell setDate:[Utility getDateToShow:comment.updateDate]];
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

- (void) setAllContentForPost:(Post *)post{
    CGFloat currentY = START_ENTITIES_Y;
    _entities = [[NSMutableArray alloc] initWithArray:[post.entities allObjects]];
    NSUInteger cnt = 0;
    for (Entity *en in _entities){
        NSMutableString *name = [NSMutableString stringWithString:en.name];
        if (en.institution.name)
            [name appendFormat:@", %@", en.institution.name];
        if (en.institution.location)
            [name appendFormat:@", %@", en.institution.location.name];
        UIButton *enButton = [[UIButton alloc] initWithFrame:CGRectMake(LEFT_OFFSET, currentY, WIDTH, ENTITY_HEIGHT)];
        enButton.tag = cnt;
        [enButton setTitle:name forState:UIControlStateNormal];
        [enButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
        enButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.view addSubview:enButton];
        [enButton addTarget:self action:@selector(entityClicked:) forControlEvents:UIControlEventTouchUpInside];
        currentY += ENTITY_HEIGHT;
        cnt++;
    }
    
    UITextView *contentView = [[UITextView alloc] initWithFrame:CGRectMake(0, currentY, WIDTH, 300)];
    contentView.text = post.content;
    [contentView setEditable:NO];
    [contentView sizeToFit];
    [self.view addSubview:contentView];
    currentY += contentView.frame.size.height;
    [_tableView setFrame:CGRectMake(0, currentY, WIDTH, 300)];
}

- (void) entityClicked:(UIButton *)button {
    [self performSegueWithIdentifier:@"viewEntitySegue" sender:button];
}


# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewEntitySegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        Entity *entity = [_entities objectAtIndex:[(UIButton *)sender tag]];
        
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
