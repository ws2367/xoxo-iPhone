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
#import "ServerConnector.h"
#import "Photo.h"
#import "Institution.h"
#import "Location.h"
#import "SuperImageView.h"
#import "KeyChainWrapper.h"
#import "ClientManager.h"
#import "Institution+MSInstitution.h"
#import "Entity+MSEntity.h"

#define VIEW_OFFSET_KEYBOARD 70
#define ANIMATION_CUTDOWN 0.05


@interface CreatePostViewController ()
{
    int photoIndex;
    UIImageView *currImageView;
    UIImageView *leftImageView; //not used
    UIImageView *rightImageView; //not used
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

@property (weak, nonatomic) ViewMultiPostsViewController *masterViewController;
@property (strong, nonatomic) CreateEntityViewController *addEntityController;

@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

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


- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _masterViewController = viewController;// Custom initialization
        _entities = [[NSMutableArray alloc] init];
//        _textView.inputAccessoryView = self.uiViewforKeyboardAttachment;
    }
    
    return self;
}


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
    
    if(_photos == nil){
        _photos = [[NSMutableArray alloc] init];
    }
    
    _toPostLock = [[NSLock alloc] init];
    _requestsToWaitLock = [[NSLock alloc] init];
    _requestsToWait = 0;
    
//    [FBSession.activeSession close];
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
    
    /*
     [_backButton setTitle:@"Back" forState:UIControlStateNormal];
     [_backButton removeTarget:self action:@selector(doneEditing:)
     forControlEvents:UIControlEventTouchUpInside];
     [_backButton addTarget:self action:@selector(backButtonPressed:)
     forControlEvents:UIControlEventTouchUpInside];
     
     _postButton.hidden = false;
     */
}




#pragma mark -
#pragma mark TextView Delegate Methods

- (void)textViewDidBeginEditing:(UITextView *) textView
{
    if ([Utility compareUIColorBetween:[textView textColor] and:[UIColor lightGrayColor]]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }
    
    
    /*
    [_backButton removeTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventAllEvents];

    [_backButton setTitle:@"Done" forState:UIControlStateNormal];
    [_backButton addTarget:self
                   action:@selector(doneEditing)
         forControlEvents:UIControlEventTouchUpInside];
    
    _postButton.hidden = true;*/
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
    
    _entityNames = [NSMutableString string];
    
    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        if (ent != [_entities lastObject])
            [_entityNames appendString:@", "];
    }
    
    self.entitiesTextField.text = (NSString *)_entityNames;
}


#pragma mark -
#pragma mark Server Communication Methods
- (void)mergeGhostEntity:(Entity *)entity InManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSFetchRequest *requestDuplicate = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbUserID = %@", entity.fbUserID];
    [requestDuplicate setPredicate:predicate];
    
    NSError *error;
    NSArray *fetchedObjects = [context executeFetchRequest:requestDuplicate error:&error];
    if (fetchedObjects == nil) {
        MSError(@"Failed to fetch duplicate entities");
        return;
    }
    
    NSString *uuid = entity.uuid;
    NSNumber *remoteID = entity.remoteID;
    NSDate *updateDate = entity.updateDate;
    Entity *entityToDelete = entity;

    for(Entity *entity in fetchedObjects) {
        if (entity.name != nil || entity.remoteID == 0) {
            entity.updateDate = updateDate;
            entity.remoteID = remoteID;
            entity.uuid = uuid;
        }
    }
    [Utility saveToPersistenceStore:context failureMessage:@"Failed to save context when merging ghost entities"];
    if (entityToDelete) [context deleteObject:entityToDelete];
}

- (void)mergeGhostEntitiesInManagedObjectContext:(NSManagedObjectContext *)context {
    // for every pairs of entities who have the same FB User ID
    // we merge them
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    [request setResultType:NSDictionaryResultType];
    [request setReturnsDistinctResults:YES];
    [request setPropertiesToFetch:@[@"fbUserID"]];
    
    // Execute the fetch.
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    if (objects == nil) {
        MSError(@"Failed to fetch fbUserID so as to merge ghost entities: %@", error);
    }
    
    for (NSString *fbUserID in objects){
        NSFetchRequest *requestDuplicate = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fbUserID = %@", fbUserID];
        [requestDuplicate setPredicate:predicate];
        
        NSArray *fetchedObjects = [context executeFetchRequest:requestDuplicate error:&error];
        if (fetchedObjects == nil) {
            MSError(@"Failed to fetch duplicate entities");
        }
        
        NSString *uuid = nil;
        NSNumber *remoteID = nil;
        NSDate *updateDate = nil;
        Entity *entityToDelete = nil;
        for(Entity *entity in fetchedObjects) {
            if (entity.remoteID != 0) {
                uuid = entity.uuid;
                remoteID = entity.remoteID;
                updateDate = entity.updateDate;
            }
            entityToDelete = entity;
        }
        for(Entity *entity in fetchedObjects) {
            if (entity.name != nil || entity.remoteID == 0) {
                entity.updateDate = updateDate;
                entity.remoteID = remoteID;
                entity.uuid = uuid;
            }
        }
        [Utility saveToPersistenceStore:context failureMessage:@"Failed to save context when merging ghost entities"];
        [context deleteObject:entityToDelete];
        
    }

}

- (void)uploadPhotosToS3ForPost:(Post *)post {
        if (![ClientManager validateCredentials]){
            NSLog(@"Abort uploading photos to S3");
            return;
        }
        for (Photo *photo in post.photos){
            NSString *photoKey = [NSString stringWithFormat:@"%@/%@.png", post.remoteID, photo.uuid];
            
            S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:photoKey inBucket:S3BUCKET_NAME];
            por.contentType = @"image/png";
            por.data = photo.image;
            S3PutObjectResponse *response = [[ClientManager s3] putObject:por];
            if (response.error != nil) {
                NSLog(@"Error while uploading photos");
            } else {
                [photo setDirty:@NO];
                MSDebug(@"Photo %@ loaded!", photo.uuid);
            }
        }
        
        // then we can save all the stuff to database
        [Utility saveToPersistenceStore:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
                         failureMessage:@"Failed to save the managed object context."];

}

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
        
        // this is for the server!
        //TODO: use remoteID instead
        [post setEntitiesUUIDs:[NSArray arrayWithArray:[[post.entities allObjects] valueForKey:@"uuid"]]];
        [post setEntitiesFBUserIDs:[NSArray arrayWithArray:[[post.entities allObjects] valueForKey:@"fbUserID"]]];
        MSDebug(@"The entities uuids of the post to be sent: %@", post.entitiesUUIDs);
        [post setDirty:@NO];
        [post setDeleted:@NO];
        [post setIsYours:@YES];
        [post setFollowing:@NO];
        [post setUuid:[Utility getUUID]];
                
        //add photos to post
        // In _photos are UIImage objects
        
        //add profile pic if there exist one
        if([_profileImageView image]){
            [_photos addObject:[_profileImageView image]];
        }
        for (UIImage *image in _photos){
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo"
                                                         inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
            
            // This will save NSData typed image to an external binary storage
            photo.image = UIImagePNGRepresentation(image);
            // dirty is a NSNumber so @YES is a literal in Obj C that is created for this purpose.
            //[NSNumber numberWithBool:] works too.
            [photo setDirty:@NO];
            [photo setDeleted:@NO];
            [photo setUuid:[Utility getUUID]];
            
            [photo setUpdateDate:[NSDate dateWithTimeIntervalSince1970:TIMESTAMP_MAX]];
            
            [post addPhotosObject:photo];
        }

        // send institutition first, then entity
        // As said in posting a comment, even if we connect the relationship,
        // we still need to set locationID in order to let the server know the relationship.
        NSMutableArray *institutionsObjects = [[NSMutableArray alloc] init];
        for (Entity *entity in post.entities) {
            if ([entity.institution.dirty boolValue]) { // we only send those dirt ones :)
                entity.institution.locationID = entity.institution.location.remoteID;
                [institutionsObjects addObject:entity.institution];
            }
        }
        
        // Let's find those dirty ones!
        NSMutableArray *entitiesObjects = [[NSMutableArray alloc] init];
        for (Entity *entity in post.entities) {
            if ([entity.dirty boolValue]) {
                entity.institutionUUID = entity.institution.uuid;
                [entitiesObjects addObject:entity];
            }
        }
        
        // send the institutions, entities and the post to the server!
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
        NSMutableArray *objectsToPush = [NSMutableArray arrayWithArray:institutionsObjects];
        [objectsToPush addObjectsFromArray:entitiesObjects];
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
        
        NSDictionary *params =
        [NSDictionary dictionaryWithObjects:@[sessionToken]
                                    forKeys:@[@"auth_token"]];
        
        RKManagedObjectRequestOperation *operation =
        [objectManager appropriateObjectRequestOperationWithObject:objectsToPush
                                                            method:RKRequestMethodPOST
                                                              path:@"posts"
                                                        parameters:params];
        
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            MSDebug(@"Uploaded posts and stuff to server, except for photos.");
            for (NSString *key in [[mappingResult dictionary] allKeys]) {
                MSDebug(@"key: %@", key);
            }
            
            
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
                [self mergeGhostEntity:entity InManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
            }
            [self uploadPhotosToS3ForPost:post];
        } failure:[Utility failureBlockWithAlertMessage:@"Can't upload posts!" block:^{
            for (NSManagedObject *managedObject in objectsToPush) {
                [managedObjectStore.mainQueueManagedObjectContext deleteObject:managedObject];
            }
            [Utility saveToPersistenceStore:managedObjectStore.mainQueueManagedObjectContext
                             failureMessage:@"Failed to delete posts and related objects persistenly."];
        }]];
        
        [operation.HTTPRequestOperation setUploadProgressBlock:
         ^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
             [_progressView setProgress:(double)totalBytesWritten/(double)totalBytesExpectedToWrite
                               animated:YES];
        }];
        
        _progressView.progress = 0.0;
        _progressView.hidden = false;
        [objectManager enqueueObjectRequestOperation:operation];
        
    }
    MSDebug(@"toPost unlock!!!");
    [_toPostLock unlock];
}

#pragma mark -
#pragma mark Image Picker Controller Methods

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picked presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    [_superImageView addPhoto:[info objectForKey:UIImagePickerControllerOriginalImage]];
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
    MSDebug(@"Selected this fb frd: %@ with fbid: %@ to integer %d", frd.name, frd.id, [frd.id integerValue]);
    BOOL hasFoundExistingEntity = [Entity findOrCreateEntityForFBUserName:frd.name withFBid:frd.id withInstitution:nil atLocationName:nil returnAsInstitution:&newFBEntity inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
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
            NSDictionary *location = [result objectForKey:@"location"];
            NSString *locationName = [location objectForKey:@"name"];
            NSArray *cityAndState = [locationName componentsSeparatedByString:@", "];
            NSString *state = [cityAndState objectAtIndex:1];
            MSDebug(@"its state %@ what?", state);

            //get its institution
            NSArray *education = [result objectForKey:@"education"];
            NSString *schoolName;
            for (id ed in education){
                if([[ed objectForKey:@"type"] isEqualToString:@"College"]){
                    id school = [ed objectForKey:@"school"];
                    schoolName = [[NSString alloc] initWithString:[school objectForKey:@"name"]];
                }
            }
            MSDebug(@"its school %@ what?", schoolName);
            
            Institution *insForFBUser;
            [Institution findOrCreateInstitutionForFBUser:schoolName atLocationName:state returnAsInstitution:&insForFBUser inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
            [newFBEntity setInstitution:insForFBUser];
            
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
