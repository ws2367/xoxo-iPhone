//
//  ViewPostViewController.m
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import "NavigationController.h"

#import "Post+MSClient.h"
#import "Comment.h"
#import "Flurry.h"
#import <FacebookSDK/FacebookSDK.h>


#import "KeyChainWrapper.h"
#import "UIColor+MSColor.h"

#import "CommentTableViewCell.h"
#import "ViewPostDisplayImageTableViewCell.h"
#import "ViewPostDisplayEntityTableViewCell.h"
#import "ViewPostDisplayCommentTableViewCell.h"
#import "ViewPostDisplayButtonBarTableViewCell.h"
#import "ViewPostDisplayContentTableViewCell.h"

#define COMMENT_ICON_MAX 29

@interface ViewPostViewController ()

@property (strong, nonatomic) Post *post;

@property (strong, nonatomic) NSString *content;

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (strong, nonatomic) NSString *names;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;

@property (strong, nonatomic) NSMutableArray *comments; //store comment pointers
@property (strong, nonatomic) NSMutableArray *entities;
@property (weak, nonatomic) IBOutlet UITableView *viewPostTableView;
@property (weak, nonatomic) IBOutlet UIView *viewThatContainsTableAndTextField;


@property (nonatomic) BOOL startEditingComment;

@property (strong, nonatomic) UIButton *maskToEndEditing;

@property (strong, nonatomic) NSMutableDictionary *commentIconDictionary;
@property (strong, nonatomic) NSMutableArray *usedIconNumber;
@property (weak, nonatomic) IBOutlet UIButton *SendButton;

@property (strong, nonatomic) NSNumber *hasRemovedObserver;
@end

#define ROW_HEIGHT 46
#define START_ENTITIES_Y 220
#define ENTITY_HEIGHT 25
#define LEFT_OFFSET 5
#define TEXT_FIELD_HEIGHT 40

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
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    self.navigationItem.rightBarButtonItem = exitButton;

    //deselect anything
//    MSDebug(@"view will appear!");
    [_viewPostTableView deselectRowAtIndexPath:[_viewPostTableView indexPathForSelectedRow] animated:YES];

}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_commentTextField setTextColor:[UIColor lightGrayColor]];
    [_commentTextField setText:@"Leave a comment..."];
    if(_startEditingComment){
        [_commentTextField becomeFirstResponder];
        
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    [_viewThatContainsTableAndTextField setBackgroundColor:[UIColor colorForYoursOrange]];
    
    //use tableview to display all content
    //[self setAllContentForPost:_post];
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken]
                                                       forKeys:@[@"auth_token"]];
    
    // Let's ask the server for the comments of this post!
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"comments"
     ofObject:self.post
     parameters:params
     success:[Utility successBlockWithDebugMessage:@"Successfully pulled comments for the post!"
                                                     block:^{[self setPost:_post];}]
     failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server!"]];
    
    // Set debug logging level. Set to 'RKLogLevelTrace' to see JSON payload
//    RKLogConfigureByName("RestKit/Network", RKLogLevelDebug);
    
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
        NSLog(@"Number of fetched comments %lu", (unsigned long)[[self.fetchedResultsController fetchedObjects] count]);
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }
    
    MSDebug(@"Post's index is %@", _post.index);
    MSDebug(@"Post's popularity is %@", _post.popularity);
    
    // remove separators of the table view
    _tableView.separatorColor = [UIColor clearColor];
    
    [self addNavigationBar];
    
    //hide scrollbar & clear separator
    [_viewPostTableView setShowsVerticalScrollIndicator:NO];
    [_viewPostTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    _commentIconDictionary = [[NSMutableDictionary alloc] init];
    
    //for 3.5 inch screen
    [self resizeTextFieldAndSendButton];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"_post.image"]) {
            [_viewPostTableView reloadData];
        [self removeObserver:self forKeyPath:@"_post.image"];//we only observe one change
    }
}

//- (void)dealloc
//{
//    [self removeObserver:self forKeyPath:@"_post.image"];
//}

-(void) resizeTextFieldAndSendButton{
    if(self.view.bounds.size.height < HEIGHT_TO_DISCRIMINATE){
        [_commentTextField setCenter:CGPointMake(WIDTH/2 - 20, self.view.bounds.size.height- 20)];
        [_viewPostTableView setFrame:CGRectMake(0, VIEW_POST_NAVIGATION_BAR_HEIGHT, WIDTH, self.view.bounds.size.height- 40 - NAVIGATION_BAR_CUT_DOWN_HEIGHT)];
        [_SendButton setCenter:CGPointMake(WIDTH - 25, self.view.bounds.size.height- 20)];
    } else {
        [_viewPostTableView setFrame:CGRectMake(0, VIEW_POST_NAVIGATION_BAR_HEIGHT, WIDTH, self.view.bounds.size.height- 40 - NAVIGATION_BAR_CUT_DOWN_HEIGHT)];
    }
}

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
    
    //we want icon
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Yours"];
    
    UIImageView *yoursView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 33)];
    [yoursView setImage:[UIImage imageNamed:@"logo_light.png"] ];
    yoursView.contentMode = UIViewContentModeScaleAspectFit;
    topNavigationItem.titleView = yoursView;
    
    
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
#pragma mark Global methods Whoever presented this view controller should call these methods
- (void) setPost:(Post *)post{
    _post = post;
    _entities = [[NSMutableArray alloc] initWithArray:[_post.entities allObjects]];
    NSArray *tempComments = [[NSArray alloc] initWithArray:[_post.comments allObjects]];
    NSArray *comments;
    comments = [tempComments sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
        NSDate *first = [(Comment *)a updateDate];
        NSDate *second = [(Comment *)b updateDate];
        return [first compare:second];
    }];
    _comments = [[NSMutableArray alloc] initWithArray:comments];
    [_viewPostTableView reloadData];
}

- (void) setStartEditingComment:(BOOL)shouldStartEdit{
    _startEditingComment = shouldStartEdit;
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
//        NSIndexPath *indexPathButton = [NSIndexPath indexPathForRow:([_entities count]+1) inSection:0];
//        [self.tableView
//         reloadRowsAtIndexPaths:@[indexPathButton]
//         withRowAnimation:UITableViewRowAnimationAutomatic];
        
        [self.viewPostTableView reloadData];
        
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
//                         _viewThatContainsTableAndTextField.frame =                       CGRectMake(_viewThatContainsTableAndTextField.frame.origin.x, keyboardRect.origin.y - self.view.frame.size.height, WIDTH, self.view.frame.size.height);
                         _viewThatContainsTableAndTextField.frame =  CGRectMake(_viewThatContainsTableAndTextField.frame.origin.x, -keyboardRect.size.height, WIDTH, HEIGHT);
                     }
                     completion:^(BOOL finished){
                         /* add it if we think this is better
                         _maskToEndEditing = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, WIDTH, keyboardRect.origin.y - TEXT_FIELD_HEIGHT)];
                         [_maskToEndEditing addTarget:self action:@selector(maskToEndEditingPressed) forControlEvents:UIControlEventTouchUpInside];
                         [self.view addSubview:_maskToEndEditing];
                          */
                         
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
                         _viewThatContainsTableAndTextField.frame =
                         CGRectMake(0,
                                    0,
                                    WIDTH,
                                    HEIGHT);
                     }
                     completion:^(BOOL finished){
                         [_maskToEndEditing removeFromSuperview];
                     }];

}

#pragma mark -
#pragma mark Button Methods

-(void)maskToEndEditingPressed{
    [_commentTextField endEditing:YES];
    [Flurry endTimedEvent:@"Comment_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
}

- (IBAction)postComment:(id)sender {

    if([_commentTextField text] == nil || [[_commentTextField text] isEqualToString:@""] ||[[_commentTextField text] isEqualToString:@"Leave a comment..."]){
        [Flurry logEvent:@"Fail_To_Comment"];
        [Utility generateAlertWithMessage:@"Please type in a comment..." error:nil];
        return;
    }


    // hide the keyboard
    [_commentTextField resignFirstResponder];
    [Flurry endTimedEvent:@"Comment_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];

    
    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment"
                                                     inManagedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext];
    

    // This is better than [comment setValue:..... forKey:@"content"]
    // because literal string is not type-checked, but @properties are.
    comment.content = _commentTextField.text;
    comment.dirty = @NO; //TODO: kill diry field when its ready to die
    comment.uuid = [Utility getUUID];
    comment.isYours = @YES;
    [comment setPost:_post];
    if(!_comments){
        _comments = [[NSMutableArray alloc] initWithObjects:comment, nil];
    } else{
        [_comments addObject:comment];
    }
    [_viewPostTableView reloadData];
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_entities count]+1) inSection:0];
//    ViewPostDisplayButtonBarTableViewCell *cell = (ViewPostDisplayButtonBarTableViewCell *)[self.viewPostTableView cellForRowAtIndexPath:indexPath];
//    [cell addCommentNumber];
//    [_viewPostTableView reloadData];
    [self scrollTableViewToBottom];
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
        MSError(@"At ViewPostViewController: user session token is not valid. Stop posting the comment.");
        [Utility generateAlertWithMessage:@"Sorry.. Something's wrong.." error:nil];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken]
                                                       forKeys:@[@"auth_token"]];

    MSDebug(@"The comment to be posted: %@", comment.content);
    // Let's push this to the server now!
    [[RKObjectManager sharedManager]
     postObject:comment
     path:nil
     parameters:params
     success:[Utility successBlockWithDebugMessage:@"Succcessfully posted the comment"
                                             block:^{
                                                 [_post incrementCommentsCount];
                                                 NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([_entities count]+1) inSection:0];
                                                 ViewPostDisplayButtonBarTableViewCell *cell = (ViewPostDisplayButtonBarTableViewCell *)[self.viewPostTableView cellForRowAtIndexPath:indexPath];
                                                 [cell addCommentNumber];
                                                 [_viewPostTableView reloadData];
                                             }]
     failure:^(RKObjectRequestOperation *operation, NSError *error) {
         [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext deleteObject:comment];
         [_comments removeLastObject];
         [_viewPostTableView reloadData];
         [Utility generateAlertWithMessage:@"No network!" error:nil];
     }];
    
    // set it back to original
    [_commentTextField setTextColor:[UIColor lightGrayColor]];
    [_commentTextField setText:@"Leave a comment..."];

}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    MSDebug(@"there are %d entities, %d comments", [_entities count], [_comments count]);

    return ([_entities count] + [_comments count] + 3);

    //    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
//    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
//    return sectionInfo.numberOfObjects;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCellIdentifier];
 
    // TODO: check if the model is empty then this will raise exception
    Comment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.content = comment.content;
    [cell setDate:[Utility getDateToShow:comment.updateDate]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];

    return cell;
}*/


#pragma mark -
#pragma mark TextField Delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    [Flurry endTimedEvent:@"Comment_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [Flurry logEvent:@"Comment_Post" withParameters:@{@"View":@"ViewPostTextField"} timed:YES];
    if ([[textField text] isEqualToString:@"Leave a comment..."]) {
        [textField setTextColor:[UIColor blackColor]];
        [textField setText:@""];
    }
//    if ([Utility compareUIColorBetween:[textField textColor] and:[UIColor lightGrayColor]]) {
//        [textField setTextColor:[UIColor blackColor]];
//        [textField setText:@""];
//    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([[textField text] isEqualToString:@""]) {
        [textField setTextColor:[UIColor lightGrayColor]];
        [textField setText:@"Leave a comment..."];
    }
}

#pragma mark -
#pragma mark Miscellaneous

- (void) setAllContentForPost:(Post *)post{
    CGFloat currentY = START_ENTITIES_Y;
    _entities = [[NSMutableArray alloc] initWithArray:[post.entities allObjects]];
    NSUInteger cnt = 0;
    for (Entity *en in _entities){
        NSMutableString *name = [NSMutableString stringWithString:en.name];
        if (en.institution)
            [name appendFormat:@", %@", en.institution];
        if (en.location)
            [name appendFormat:@", %@", en.location];
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


#pragma mark -
#pragma mark Table Data Source Methods
/*
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
    id <NSFetchedResultsSectionInfo> sectionInfo = fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}*/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row == 0){
        UIImage *thisImage = nil;
        if (_post.image == nil) {
            thisImage = [UIImage imageNamed:@"background.png"];
        } else {
            thisImage = [[UIImage alloc] initWithData:_post.image];
        }
        if(thisImage.size.height > VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT){
            return VIEW_POST_DISPLAY_IMAGE_CELL_HEIGHT;
        } else{
            return thisImage.size.height;
        }
    } else if(indexPath.row <= [_entities count]){
        return VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT;
    } else if(indexPath.row == ([_entities count] + 1)){
        return VIEW_POST_DISPLAY_BUTTON_BAR_HEIGHT;
    } else if(indexPath.row == ([_entities count] + 2)){
        CGRect rectSize = [_post.content boundingRectWithSize:(CGSize){WIDTH, CGFLOAT_MAX}
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                             attributes:[Utility getViewPostDisplayContentFontDictionary] context:nil];

        return ceilf(rectSize.size.height)+60;
    } else{
        Comment *comment =[_comments objectAtIndex:(indexPath.row - [_entities count] - 3 )];
        if([[comment content] length]<25){
            return VIEW_POST_DISPLAY_COMMENT_HEIGHT;
        }else{
            CGRect rectSize = [[comment content] boundingRectWithSize:(CGSize){WIDTH-60, CGFLOAT_MAX}
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:@{
                                                                           NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                           } context:nil];
            CGFloat textViewEnd = ceil(rectSize.size.height)+20;

            if(textViewEnd > VIEW_POST_DISPLAY_COMMENT_HEIGHT){
                return textViewEnd;
            } else{
                return VIEW_POST_DISPLAY_COMMENT_HEIGHT;
            }
        }
    }
}

// This is where cells got data and set up
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    MSDebug(@"Row at %d. entities count %d",indexPath.row, [_entities count]);
    if(indexPath.row == 0){
        ViewPostDisplayImageTableViewCell *cell = [_viewPostTableView dequeueReusableCellWithIdentifier:viewPostDisplayImageCellIdentifier];
        if (!cell){
            cell = [[ViewPostDisplayImageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewPostDisplayImageCellIdentifier];
        }
        if (_post.image == nil) {
            //Add observer to respond to the change of image content
            [self addObserver:self forKeyPath:@"_post.image" options:NSKeyValueObservingOptionNew context:nil];
            [cell setPostImage:[UIImage imageNamed:@"background.png"]];
        } else {
            [cell setPostImage:[[UIImage alloc] initWithData:_post.image]];
        }
        return cell;
    } else if(indexPath.row <= [_entities count]){
        ViewPostDisplayEntityTableViewCell *cell = [_viewPostTableView dequeueReusableCellWithIdentifier:viewPostDisplayEntityCellIdentifier];
        if (!cell){
            cell = [[ViewPostDisplayEntityTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewPostDisplayEntityCellIdentifier];
        }
        Entity *en =[_entities objectAtIndex:(indexPath.row - 1)];
        [cell setEntity:en];
        return cell;
    } else if(indexPath.row == ([_entities count] + 1)){
        ViewPostDisplayButtonBarTableViewCell *cell = [_viewPostTableView dequeueReusableCellWithIdentifier:viewPostDisplayButtonBarCellIdentifier];
        if (!cell){
            cell = [[ViewPostDisplayButtonBarTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewPostDisplayButtonBarCellIdentifier];
        }
        [cell addCommentAndFollowNumbersWithCommentsCount:_post.commentsCount FollowersCount:_post.followersCount hasFollowed:[_post.following boolValue]];
        cell.delegate = self;
        return cell;

    }else if(indexPath.row == ([_entities count] + 2)){
        ViewPostDisplayContentTableViewCell *cell = [_viewPostTableView dequeueReusableCellWithIdentifier:viewPostDisplayContentCellIdentifier];
        if (!cell){
            cell = [[ViewPostDisplayContentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewPostDisplayContentCellIdentifier];
        }
        [cell setContent:_post.content andDate:_post.updateDate];
        return cell;
    }else{
        ViewPostDisplayCommentTableViewCell *cell = [_viewPostTableView dequeueReusableCellWithIdentifier:viewPostDisplayCommentCellIdentifier];
        if (!cell){
            cell = [[ViewPostDisplayCommentTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:viewPostDisplayCommentCellIdentifier];
        }
        Comment *comment =[_comments objectAtIndex:(indexPath.row - [_entities count] - 3 )];
        NSString *commentIconFileString;
//        MSDebug(@"anonymized %@", [comment anonymizedUserID]);
        commentIconFileString = [[[NSString stringWithFormat:@"comment-icon-"] stringByAppendingString:[NSString stringWithFormat:@"%@",[comment anonymizedUserID]]] stringByAppendingString:@".png"];
        
        if([[comment anonymizedUserID] isEqualToNumber:[NSNumber numberWithInt:0]]){
            [cell setComment:comment withIcon:nil];
            return cell;
        }
        
        /*
        if(_commentIconDictionary[[NSString stringWithFormat:@"%@",[comment anonymizedUserID]]] == nil){
            NSInteger getNum;
            if([_usedIconNumber count]<COMMENT_ICON_MAX){
                do {
                    getNum = rand()%COMMENT_ICON_MAX + 1;
                    MSDebug(@"the randome number i got %d",getNum);
                } while ([_usedIconNumber containsObject:[NSNumber numberWithInt:getNum]]);
                [_usedIconNumber addObject:[NSNumber numberWithInt:getNum]];
                commentIconFileString = [[[NSString stringWithFormat:@"comment-icon-"] stringByAppendingString:[NSString stringWithFormat:@"%d",getNum]] stringByAppendingString:@".png"];
                [_commentIconDictionary setObject:[NSNumber numberWithInt:getNum] forKey:[NSString stringWithFormat:@"%@",[comment anonymizedUserID]]];
            } else{
                getNum = rand()%COMMENT_ICON_MAX + 1;
                [_commentIconDictionary setValue:[NSNumber numberWithInt:getNum] forKey:[NSString stringWithFormat:@"%@",[comment anonymizedUserID]]];
                commentIconFileString = [[[NSString stringWithFormat:@"comment-icon-"] stringByAppendingString:[NSString stringWithFormat:@"%d",getNum]] stringByAppendingString:@".png"];
            }
        } else{
            NSNumber *num = [_commentIconDictionary valueForKey:[NSString stringWithFormat:@"%@",[comment anonymizedUserID]]];
            commentIconFileString = [[[NSString stringWithFormat:@"comment-icon-"] stringByAppendingString:[NSString stringWithFormat:@"%d",[num integerValue]]] stringByAppendingString:@".png"];
        }*/
        
        [cell setComment:comment withIcon:commentIconFileString];
        return cell;
    }
    
}

#pragma mark -
#pragma mark TableView Delegate Methods
// This has to call parent controller
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    [_masterController startViewingPostForPost:post];
}*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.row <= [_entities count] && indexPath.row != 0){
        [self performSegueWithIdentifier:@"viewEntitySegue" sender:indexPath];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.row <= [_entities count] && indexPath.row != 0){
        return indexPath;
    } else{
        return nil;
    }
}



# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewEntitySegue"]){
        [Flurry endTimedEvent:@"Comment_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
        [Flurry logEvent:@"View_Entity" withParameters:@{@"View":@"ViewPost"}];
        ViewEntityViewController *nextController = segue.destinationViewController;
        
//        Entity *entity = [_entities objectAtIndex:[(UIButton *)sender tag]];
        NSIndexPath *thisIndexPath = (NSIndexPath *)sender;
        Entity *entity = [_entities objectAtIndex:(thisIndexPath.row - 1)];
        [nextController setEntity:entity];
    }
    else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        [Flurry endTimedEvent:@"Comment_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
        [Flurry logEvent:@"View_Post" withParameters:@{@"View":@"ViewPost"}];
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [nextController setPost:post];
    }
}


# pragma mark -
#pragma mark TableView helper method
- (void)scrollTableViewToBottom
{
    CGFloat yOffset = 0;
    
    if (_viewPostTableView.contentSize.height > _viewPostTableView.bounds.size.height) {
        yOffset = _viewPostTableView.contentSize.height - _viewPostTableView.bounds.size.height;
    }
    
    [_viewPostTableView setContentOffset:CGPointMake(0, yOffset) animated:NO];
}
# pragma mark -
#pragma mark BigPostTableViewCell delegate method

-(void)sharePost:(id)sender{
    [Flurry logEvent:@"Share_Post" withParameters:@{@"View":@"ViewPost"} timed:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share this post on your Facebook wall?" message:@"" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes", nil];
    [alert show];
//    MultiplePeoplePickerViewController *picker = [[MultiplePeoplePickerViewController alloc] init];
//    picker.delegate = self;
//    [self presentViewController:picker animated:YES completion:nil];
}


-(void)commentPost:(id)sender{
    [Flurry logEvent:@"Comment_Post" withParameters:@{@"View":@"ViewPostCommentButton"} timed:YES];
    //indicate we want to comment
    [_commentTextField becomeFirstResponder];
}
- (void) followPost:(id)sender;
{
    [_post sendFollowRequestWithFailureBlock:^{
        [Utility generateAlertWithMessage:@"Failed to follow/unfollow!" error:nil];
    }];
}


-(void)reportPost:(id)sender{
    [Flurry logEvent:@"Report_Post" withParameters:@{@"View":@"ViewPost"} timed:YES];
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



#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) handleNumbers:(NSSet *)selectedNumbers{
    
    if (![KeyChainWrapper isSessionTokenValid]) {
        [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
        return;
    }
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, [selectedNumbers allObjects]]
                                                       forKeys:@[@"auth_token", @"numbers"]];
    
    NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"share_post"
                                                                                          object:_post
                                                                                      parameters:params];
    
    RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCompletionBlockWithSuccess:nil
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         [Utility generateAlertWithMessage:@"Network problem" error:error];
                                     }];
    
    NSOperationQueue *operationQueue = [NSOperationQueue new];
    [operationQueue addOperation:operation];
    
    
}

- (void)donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [self dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    
    if ([selectedNumbers count] > 0) {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
        [self handleNumbers:selectedNumbers];
    } else {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}


#pragma mark -
#pragma mark alertView delegate method

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //assume only share post use this method
    if(buttonIndex == 1){
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
        [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self postImageOnFB:image];
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];

        // report this share to server
        ASYNC({
            [_post reportShareToServerWithFailureBlock:^{[Utility generateAlertWithMessage:@"Network problem" error:nil];}];
        });

    } else{
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}


-(void) postImageOnFB:(UIImage *)image{
    BOOL canPresent = [FBDialogs canPresentShareDialogWithPhotos];
    NSLog(@"canPresent: %d", canPresent);
    
    FBShareDialogPhotoParams *params = [[FBShareDialogPhotoParams alloc] init];
    params.photos = @[image];
    
    FBAppCall *appCall = [FBDialogs presentShareDialogWithPhotoParams:params
                                                          clientState:nil
                                                              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                  if (error) {
                                                                      NSLog(@"Error: %@", error.description);
                                                                  } else {
                                                                      NSLog(@"Success!");
                                                                  }
                                                              }];
    if (!appCall) {
        [self performPublishAction:^{
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorAlertUser
            | FBRequestConnectionErrorBehaviorRetry;
            
            [connection addRequest:[FBRequest requestForUploadPhoto:image]
                 completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                     [Utility generateAlertWithMessage:@"It is posted!" error:nil];
                     if (FBSession.activeSession.isOpen) {
                     }
                 }];
            [connection start];
            
        }];
    }
}

- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    
}



#pragma mark UIActionSheet delegate method
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        [Flurry endTimedEvent:@"Report_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
        
        [_post sendReportRequestWithFailureBlock:^{[Utility generateAlertWithMessage:@"Network problem" error:nil];}];
    } else {
        [Flurry endTimedEvent:@"Report_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}

-(void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    
}






@end
