//
//  CreatePostViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//



#import "CreatePostViewController.h"
#import "CreateEntityViewController.h"
#import "ViewMultiPostsViewController.h"

#import "SuperImageView.h"
#import "KeyChainWrapper.h"
#import "ClientManager.h"

#import "Post+MSS3Client.h"
#import "Entity+MSEntity.h"
#import "UIColor+MSColor.h"

#define VIEW_OFFSET_KEYBOARD 70
#define ANIMATION_CUTDOWN 0.05


@interface CreatePostViewController ()
{
    int photoIndex;
    UIImageView *currImageView;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

// for image picker controller
@property (weak, nonatomic) IBOutlet SuperImageView *superImageView;
@property (nonatomic, retain) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet UITextField *entitiesTextField;

// store data showed in the views here
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableString *content;
@property (strong, nonatomic) NSMutableString *entityNames;
//for friend picker
@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;
@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicView;

//for fb request concurrency
@property (atomic) int32_t requestsToWait;
@property (strong, nonatomic)NSLock *requestsToWaitLock;
@property (strong, nonatomic)NSLock *toPostLock;
@property (strong, nonatomic) NSMutableString *nameList;

//for grabbing facebook profile image
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;


@end


@implementation CreatePostViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //To make the border look very close to a UITextField
    [_textView.layer setBorderColor:[[[UIColor grayColor] colorWithAlphaComponent:0.5] CGColor]];
    [_textView.layer setBorderWidth:0.5];
    
    //The rounded corner part, where you specify your view's corner radius:
    _textView.layer.cornerRadius = 5;
    _textView.clipsToBounds = YES;
    
    //attach input accessory view to textview
    [_textView setInputAccessoryView:[self createInputAccessoryView]];
    
    photoIndex = 0;
    // Do any additional setup after loading the view from its nib.
    
    //do swipe in superImageView
    /*
    [_superImageView addGestureRecognizer:[[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(swipeImage:)]];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(swipeImage:)];
    
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_superImageView addGestureRecognizer:recognizer];
    */
     
    _entityNames = [NSMutableString string];
    
    if (_content == NULL) _content = [NSMutableString string];
    else [_textView setText:@"sadasda"];
    
    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        if (ent != [_entities lastObject])
            [_entityNames appendString:@", "];
    }
    
    self.entitiesTextField.text = (NSString *)_entityNames;
    
    
    //initialize locks
    if(!_toPostLock){
    _toPostLock = [[NSLock alloc] init];
    }
    if(!_requestsToWaitLock){
    _requestsToWaitLock = [[NSLock alloc] init];
    }
    _requestsToWait = 0;
    
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getMultiPostsContentFontDictionary]];
    [self.view addSubview:topNavigationBar];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    [exitButton setTintColor:[UIColor whiteColor]];
    
    [exitButton setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Create Post"];
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
    
    [self addAddPhotoButton];
    [self addDoneCreatingPostButton];

}
#pragma mark -
#pragma mark Navigation Bar Button Methods
- (void)exitButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
#pragma mark View Will Appear
- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    // hide the progress view first
    _progressView.hidden = true;
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Create Button Methods
- (void) addAddPhotoButton{
    UIImage *addPhotoButtonImage = [UIImage imageNamed:@"icon-add_photo.png"];
    UIButton *addPhotoButton =[[UIButton alloc] initWithFrame:CGRectMake(120, 140, addPhotoButtonImage.size.width, addPhotoButtonImage.size.height)];
    [addPhotoButton setImage:addPhotoButtonImage forState:UIControlStateNormal];
    [addPhotoButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addPhotoButton];
}

-(void)addDoneCreatingPostButton{
    UIImage *doneCreatingButtonImage = [UIImage imageNamed:@"icon-check.png"];
    UIButton *doneCreatingButton =[[UIButton alloc] initWithFrame:CGRectMake(130, 500, doneCreatingButtonImage.size.width, doneCreatingButtonImage.size.height)];
    [doneCreatingButton setImage:doneCreatingButtonImage forState:UIControlStateNormal];
    [doneCreatingButton addTarget:self action:@selector(doneCreatingPost:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:doneCreatingButton];
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
                                    keyboardRect.origin.y - HEIGHT + VIEW_OFFSET_KEYBOARD,
                                    WIDTH,
                                    HEIGHT);
                     }
                     completion:^(BOOL finished){
                     }];


}

//Oooooops. While the keyboard is moving, the super view leaks itself on the screen
//TODO: make a background view to prevent it
- (void) handleKeyboardWillHide:(NSNotification *)paramNotification{
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION - ANIMATION_CUTDOWN
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseOut
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
#pragma mark Input Accessory View Methods

-(UIView *)createInputAccessoryView{
    
    // Note that the frame width (third value in the CGRectMake method)
    // should change accordingly in landscape orientation.
    UIView *res = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                           0.0,
                                                           WIDTH,
                                                           35.0)];
    
    [res setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3]];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    
    [doneButton setFrame: CGRectMake((WIDTH - 60.0), 0.0, 50.0, 35.0)];
    
    [doneButton setTitle: @"Done" forState: UIControlStateNormal];
    
    [doneButton setTitleColor:[UIColor colorWithRed:0.945 green:0.353 blue:0.133 alpha:1.0] forState:UIControlStateNormal];
    
    [doneButton addTarget: self action: @selector(doneEditing) forControlEvents: UIControlEventTouchUpInside];
    
    [res addSubview:doneButton];
    
    return res;
}

- (void)doneEditing {
    [_textView resignFirstResponder];
    }




#pragma mark -
#pragma mark TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *) textView
{
    if ([Utility compareUIColorBetween:[textView textColor] and:[UIColor lightGrayColor]]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([[textView text] isEqualToString:@""]) {
        [textView setText:@"Write here!"];
        [textView setTextColor:[UIColor lightGrayColor]];
    }
}

#pragma mark -
#pragma mark Button Methods
- (IBAction)doneCreatingPost:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self uploadPostAndRelatedObjects];
    });
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)addPhoto:(id)sender {
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    [self presentViewController:_picker animated:YES completion:nil];
}


-(void) addEntity:(Entity *)en{
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    [_entities addObject:en];
    
    if(!_nameList){
        _nameList = [[NSMutableString alloc] init];
    }
    [_nameList appendString:[en name]];
    _entityNames = [NSMutableString string];
    
    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        if (ent != [_entities lastObject])
            [_entityNames appendString:@", "];
    }
    
    self.entitiesTextField.text = _nameList;
}


#pragma mark -
#pragma mark Server Communication Methods

- (void)uploadPostAndRelatedObjects {
    MSDebug(@"wanna lock");
    [_toPostLock lock];
    MSDebug(@"got lock");
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    Post *post =[NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                              inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];

    if (post != nil) {
        post.content = _textView.text;
        
        //set up relationship with entities
        [post setEntities:[NSSet setWithArray:_entities]];
        
        // dirty is a NSNumber so @YES is a literal in Obj C that is created for this purpose.
        [post setDirty:@NO];
        [post setIsYours:@YES];
        [post setFollowing:@NO];
        [post setUuid:[Utility getUUID]];
                
        //add photos to post
        // In _photos are UIImage objects
        
        //add profile pic if there exist one
        if(!_photos && [_profileImageView image]){
            [_photos addObject:[_profileImageView image]];
        }
        
        for (UIImage *image in _photos){
            // This will save NSData typed image to an external binary storage
            post.image = UIImagePNGRepresentation(image);
            
        }

        // Let's find those dirty ones!
        NSMutableArray *entitiesObjects = [[NSMutableArray alloc] init];
        for (Entity *entity in post.entities) {
            //if ([entity.dirty boolValue]) {
                [entitiesObjects addObject:entity];
            //}
        }
        
        // send the entities and the post to the server!
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
        NSMutableArray *objectsToPush = [NSMutableArray arrayWithArray:entitiesObjects];
        [objectsToPush addObject:post];
        
        // check if seesion token is valid
        if (![KeyChainWrapper isSessionTokenValid]) {
            NSLog(@"At CreatePostViewController: user session token is not valid. Stop uploading post.");
            for (NSManagedObject *managedObject in objectsToPush) {
                [managedObjectStore.mainQueueManagedObjectContext deleteObject:managedObject];
            }
            [Utility saveToPersistenceStore:managedObjectStore.mainQueueManagedObjectContext
                             failureMessage:@"Failed to delete posts and related objects persistenly."];
            [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
            return;
        }
        
        NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
        
        NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken] forKeys:@[@"auth_token"]];
        
        RKManagedObjectRequestOperation *operation =
        [objectManager appropriateObjectRequestOperationWithObject:objectsToPush
                                                            method:RKRequestMethodPOST
                                                              path:@"posts"
                                                        parameters:params];
        
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            MSDebug(@"Uploaded posts and stuff to server, except for photos.");
            
            // Note that here the class of the value returned could be either NSMutableArray or Entity
            // We need to deal with them separtely
            id value = [[mappingResult dictionary] valueForKey:@"Entity"];
            NSArray *entities = nil;
            if ([value isKindOfClass:[Entity class]]) {
                entities = [NSArray arrayWithObject:value];
            } else {
                entities = [NSArray arrayWithArray:value];
            }
                
            for (Entity *entity in entities) {
                MSDebug(@"Entity to merge has remoteID: %@", entity.remoteID);
                [entity updateUUIDinManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
            }
            [post uploadImageToS3];
            
        } failure:[Utility failureBlockWithAlertMessage:@"Can't upload posts!" block:^{
            for (NSManagedObject *managedObject in objectsToPush) {
                [managedObjectStore.mainQueueManagedObjectContext deleteObject:managedObject];
            }
            [Utility saveToPersistenceStore:managedObjectStore.mainQueueManagedObjectContext
                             failureMessage:@"Failed to delete posts and related objects persistenly."];
        }]];
        
        /* Show progress bar
         *
        [operation.HTTPRequestOperation setUploadProgressBlock:
         ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
             [_progressView setProgress:(double)totalBytesWritten/(double)totalBytesExpectedToWrite
                               animated:YES];
        }];
        
        _progressView.progress = 0.0;
        _progressView.hidden = false;
        [objectManager enqueueObjectRequestOperation:operation];
         */
        
    }
    MSDebug(@"toPost unlock!!!");
    [_toPostLock unlock];
}

#pragma mark -
#pragma mark Image Picker Controller Methods

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picked presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [_superImageView addPhoto:[info objectForKey:UIImagePickerControllerOriginalImage]];
    _photos = nil;
    _photos = [[NSMutableArray alloc] init];
    [_photos addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    /*
    [_photos addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    photoIndex = (int)[_photos count] - 1;
    
    [currImageView removeFromSuperview];
    
    currImageView =
    [[UIImageView alloc]
     initWithFrame:CGRectMake(0,
                              _superImageView.frame.origin.y,
                              _superImageView.frame.size.width-10,
                              _superImageView.frame.size.height)];
    
    [currImageView setImage:[_photos objectAtIndex:photoIndex]];
    
    [self.view addSubview:currImageView];
    */
}


#pragma mark -
#pragma mark FacebookFriendPicker initiation
- (IBAction)fbFriendButtonPressed:(id)sender {
    
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        MSDebug(@"no session");
        // if the session is closed, then we open it here, and establish a handler for state changes
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_birthday",@"friends_hometown", @"friends_birthday",@"friends_location",@"friends_education_history",@"friends_work_history",                              nil];
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self fbFriendButtonPressed:sender];
                                          }
                                      }];
        return;
    }
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Pick Friends";
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

# pragma mark -
#pragma mark - FBFriendPickerDelegate method
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    [_toPostLock tryLock];
    id<FBGraphUser> firstFrd = [self.friendPickerController.selection firstObject];
    _profilePicView.profileID = firstFrd.id;
    NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", firstFrd.id];
    [_profileImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    _profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    for (id<FBGraphUser> frd in self.friendPickerController.selection) {
        _profilePicView.profileID = frd.id;
        [self processFBUser:frd];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}


# pragma mark -
#pragma mark - process every fb friend picked
- (void) processFBUser:(id<FBGraphUser>) frd{
    [_requestsToWaitLock lock];
    _requestsToWait++;
    MSDebug(@"Plus request to %d", _requestsToWait);
    [_requestsToWaitLock unlock];
    if(!_nameList){
        _nameList = [[NSMutableString alloc] init];
    }
    [_nameList appendString:frd.name];
    _entitiesTextField.text = _nameList;

    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    Entity *newFBEntity;
    MSDebug(@"Selected this fb frd: %@ with fbid: %@ to integer %lu", frd.name, frd.id, [frd.id integerValue]);
    BOOL hasFoundExistingEntity = [Entity
                                   findOrCreateEntityForFBUserName:frd.name
                                   withFBid:frd.id
                                   withInstitution:nil
                                   atLocation:nil
                                   returnAsEntity:&newFBEntity
                                   inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
                                   
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    [_entities addObject:newFBEntity];
    
    MSDebug(@"has found existing entity? %d", hasFoundExistingEntity);
    if(hasFoundExistingEntity){
        [_requestsToWaitLock lock];
        _requestsToWait--;
        MSDebug(@"Minus request to %d", _requestsToWait);
        if(_requestsToWait == 0){
            [_toPostLock unlock];
             MSDebug(@"toPost unlock!!!");
        }
        [_requestsToWaitLock unlock];
        MSDebug(@"Has Found existing entity %@ with fbid: %@", newFBEntity.name, newFBEntity.fbUserID);
    } else {
        FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                      graphPath:frd.id];
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            
            //get its state
            NSString *state = nil;
            NSDictionary *location = [result objectForKey:@"location"];
            if (location) {
                NSString *locationName = [location objectForKey:@"name"];
                if (locationName) {
                    NSArray *cityAndState = [locationName componentsSeparatedByString:@", "];
                    if (cityAndState) {
                        state = [cityAndState objectAtIndex:1];
                        [newFBEntity setLocation:state];
                    }
                }
            }
            
            //get its institution
            NSString *schoolName = nil;
            NSArray *education = [result objectForKey:@"education"];
            if (education) {
                for (id ed in education){
                    if([[ed objectForKey:@"type"] isEqualToString:@"College"]){
                        id school = [ed objectForKey:@"school"];
                        schoolName = [[NSString alloc] initWithString:[school objectForKey:@"name"]];
                        [newFBEntity setInstitution:schoolName];
                    }
                }
            }
            
            MSDebug(@"its state %@ what?", state);
            MSDebug(@"its school %@ what?", schoolName);
            
            [_requestsToWaitLock lock];
            _requestsToWait--;
            MSDebug(@"Minus request to %d, is it true? %d", _requestsToWait, _requestsToWait == 0);
            if(_requestsToWait == 0){
                [_toPostLock unlock];
                MSDebug(@"toPost unlock!!!");
            }
            [_requestsToWaitLock unlock];
        }];

    }
}



# pragma mark -
#pragma mark - Navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"createEntitySegue"]){
        CreateEntityViewController *nextController = segue.destinationViewController;
        nextController.delegate = self;
    } else
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
