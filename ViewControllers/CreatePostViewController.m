//
//  CreatePostViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//



#import "CreatePostViewController.h"
#import "CreateEntityViewController.h"

#import "SuperImageView.h"
#import "KeyChainWrapper.h"
#import "ClientManager.h"

#import "Post+MSClient.h"
#import "Entity+MSEntity.h"
#import "UIColor+MSColor.h"

#define VIEW_OFFSET_KEYBOARD 100
#define ANIMATION_CUTDOWN 0.05
#define OFFSET_X_FOR_DISPLAY_ENTITIES 6
#define OFFSET_Y_FOR_DISPLAY_ENTITIES 5
#define HEIGHT_FOR_EACH_ENTITY_ROW 38
#define START_DISPLAYING_ENTITIES 308
#define DELETE_BUTTON_OFFSET_X 116

@interface CreatePostViewController ()
{
    int photoIndex;
    UIImageView *currImageView;
}

@property (weak, nonatomic)IBOutlet UITextView *textView;

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


@property (strong, nonatomic) NSMutableString *nameList;

//for grabbing facebook profile image
@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) NSString *currentDisplayFBID;

@property (strong, nonatomic) UIButton *doneCreatingPostButton;
@property (strong, nonatomic) UIButton *addPhotoButton;

@property (strong, nonatomic) UIView *whiteBackgroundRow1;
@property (strong, nonatomic) UIView *whiteBackgroundRow2;
@property (strong, nonatomic) UIView *whiteBackgroundRow3;
@property (strong, nonatomic) CAShapeLayer *verticalLineRow1;
@property (strong, nonatomic) CAShapeLayer *verticalLineRow2;
@property (strong, nonatomic) CAShapeLayer *verticalLineRow3;
@property (strong, nonatomic) CAShapeLayer *horizontalLineRow1;
@property (strong, nonatomic) CAShapeLayer *horizontalLineRow2;
@property (strong, nonatomic) CAShapeLayer *horizontalLineRow3;
@property (strong, nonatomic) UIButton *nameButton1;
@property (strong, nonatomic) UIButton *nameButton2;
@property (strong, nonatomic) UIButton *nameButton3;
@property (strong, nonatomic) UIButton *nameButton4;
@property (strong, nonatomic) UIButton *nameButton5;
@property (strong, nonatomic) UIButton *nameButton6;
@property (strong, nonatomic) UILabel *instiLabel1;
@property (strong, nonatomic) UILabel *instiLabel2;
@property (strong, nonatomic) UILabel *instiLabel3;
@property (strong, nonatomic) UILabel *instiLabel4;
@property (strong, nonatomic) UILabel *instiLabel5;
@property (strong, nonatomic) UILabel *instiLabel6;

@property (strong, nonatomic) UIButton *deleteButton1;
@property (strong, nonatomic) UIButton *deleteButton2;
@property (strong, nonatomic) UIButton *deleteButton3;
@property (strong, nonatomic) UIButton *deleteButton4;
@property (strong, nonatomic) UIButton *deleteButton5;
@property (strong, nonatomic) UIButton *deleteButton6;


@end


@implementation CreatePostViewController


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor colorForYoursWhite];
    
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
    
    [_profileImageView setImage:[UIImage imageNamed:@"background.png"]];
//    [self addContentTextView];
    [self addAddPhotoButton];
    [self addDoneCreatingPostButton];
    [self addAddFBFriendButton];
    [_textView  setFont: [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:18]];
    
    
    
}
#pragma mark -
#pragma mark Navigation Bar Button Methods
- (void)exitButtonPressed:(id)sender{
    [Flurry endTimedEvent:@"Create_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
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
    _addPhotoButton =[[UIButton alloc] initWithFrame:CGRectMake(120, 130, addPhotoButtonImage.size.width, addPhotoButtonImage.size.height)];
    [_addPhotoButton setImage:addPhotoButtonImage forState:UIControlStateNormal];
    [_addPhotoButton addTarget:self action:@selector(addPhoto:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addPhotoButton];
}

-(void)addDoneCreatingPostButton{
    UIImage *doneCreatingButtonImage = [UIImage imageNamed:@"icon-check.png"];
    _doneCreatingPostButton =[[UIButton alloc] initWithFrame:CGRectMake(130, self.view.bounds.size.height - 68, doneCreatingButtonImage.size.width, doneCreatingButtonImage.size.height)];
    [_doneCreatingPostButton setImage:doneCreatingButtonImage forState:UIControlStateNormal];
    [_doneCreatingPostButton addTarget:self action:@selector(doneCreatingPost:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneCreatingPostButton];
}
-(void)addAddFBFriendButton{
    UIImageView *addImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-add.png"]];
    [addImageView setCenter:CGPointMake(95, 283)];
    UIButton *addFBFriendButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 263, WIDTH, 45)];
    [addFBFriendButton setBackgroundColor:[UIColor colorForYoursFacebookBlue]];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Facebook Friends" attributes:[Utility getCreatePostViewAddFriendButtonFontDictionary]];
    [addFBFriendButton setAttributedTitle:title forState:UIControlStateNormal];
    [addFBFriendButton addTarget:self action:@selector(fbFriendButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addFBFriendButton];
    [self.view addSubview:addImageView];
}

//-(void)addContentTextView{
//    _textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 315, WIDTH - 30, 200)];
//    _textView.delegate = self;
//    [self.view addSubview:_textView];
//}

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
    
    CGFloat offsetToMove;
    NSUInteger cnt = [_entities count];
    if(cnt > 4){
        offsetToMove = VIEW_OFFSET_KEYBOARD - 45;
    } else if(cnt > 2){
        offsetToMove = VIEW_OFFSET_KEYBOARD - 30;
    } else if(cnt > 0){
        offsetToMove = VIEW_OFFSET_KEYBOARD - 15;
    } else {
        offsetToMove = VIEW_OFFSET_KEYBOARD;
    }
    
    // set the whole view to be right above keyboard
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.view.frame =
                         CGRectMake(self.view.frame.origin.x,
                                    keyboardRect.origin.y - self.view.frame.size.height + offsetToMove,
                                    WIDTH,
                                    self.view.frame.size.height);
                         [_doneCreatingPostButton setAlpha:0];
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
                                    self.view.frame.size.height);
                         [_doneCreatingPostButton setAlpha:1];
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
    if([[textView text] isEqualToString:@"Write here!"]){
        [Flurry logEvent:@"Edit_Content" withParameters:@{@"Start_Fresh":FL_YES} timed:YES];
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    } else {
        [Flurry logEvent:@"Edit_Content" withParameters:@{@"Start_Fresh":FL_NO} timed:YES];
    }
    /*
    if ([Utility compareUIColorBetween:[textView textColor] and:[UIColor lightGrayColor]]) {
        [textView setText:@""];
        [textView setTextColor:[UIColor blackColor]];
    }*/
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([[textView text] isEqualToString:@""]) {
        [Flurry endTimedEvent:@"Edit_Content" withParameters:@{@"Has_Content":FL_NO}];
        [textView setText:@"Write here!"];
        [textView setTextColor:[UIColor lightGrayColor]];
    } else {
        [Flurry endTimedEvent:@"Edit_Content" withParameters:@{@"Has_Content":FL_YES}];
    }
}

#pragma mark -
#pragma mark Button Methods

-(void)deleteButtonPressed:(id)sender{
    Entity *entity = [_entities objectAtIndex:[sender tag] - 1];
    NSString *thisEntityID = entity.fbUserID;
    [_entities removeObjectAtIndex:[sender tag] - 1];
    if([thisEntityID isEqualToString:_currentDisplayFBID]){
        if([_entities count]){
            Entity *firstEn = [_entities firstObject];
            [self setProfileImageViewWithfbUserID:firstEn.fbUserID];
        } else{
            [self setProfileImageViewWithfbUserID:nil];
        }
    }
    [self reloadSelectedEntitiesSection];
}
-(void)nameButtonPressed:(id)sender{
    Entity *pressedEntity = [_entities objectAtIndex:[sender tag] - 1];
    [self setProfileImageViewWithfbUserID:pressedEntity.fbUserID];
}

- (void)doneCreatingPost:(id)sender {
    if([[_textView text] isEqualToString:@"Write here!"]){
        [Flurry logEvent:@"Fail_To_Create_Post" withParameters:@{@"type":@"No Content"}];
        [Utility generateAlertWithMessage:@"Please type in post content..." error:nil];
        return;
    }
    if([_entities count] == 0 || _entities == nil){
        [Flurry logEvent:@"Fail_To_Create_Post" withParameters:@{@"type":@"No FB Friends tagged"}];
        [Utility generateAlertWithMessage:@"Please tag a friend..." error:nil];
        return;
    }
    [Flurry endTimedEvent:@"Create_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
    [self dismissViewControllerAnimated:YES completion:nil];

    //to let UI scroll to it
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    Post *post =[NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                              inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
    if(_multiPostsTabBarController){
        [_multiPostsTabBarController createPostsViewControllerWantsToSwitchAndScrollToPost:post];
    }
    if(_viewEntityViewController){
        [_viewEntityViewController scrollToPost:post];
    }

    ASYNC({
        [self uploadPostAndRelatedObjects:post withObjectStore:managedObjectStore];
    });
//    [self.navigationController popViewControllerAnimated:true];
}

- (void)addPhoto:(id)sender {
    [Flurry logEvent:@"Add_Photo" withParameters:nil timed:YES];
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
    if([_entities count]<6){
        [_entities addObject:en];
    }
    [self reloadSelectedEntitiesSection];
    [self setProfileImageViewWithfbUserID:en.fbUserID];
}


#pragma mark -
#pragma mark Server Communication Methods

- (void)uploadPostAndRelatedObjects:(Post *)post withObjectStore:(RKManagedObjectStore *)managedObjectStore{

    if (post != nil) {
        post.content = _textView.text;
        
        //set up relationship with entities
        [post setEntities:[NSSet setWithArray:_entities]];
        
        // dirty is a NSNumber so @YES is a literal in Obj C that is created for this purpose.
        [post setDirty:@NO];
        [post setIsYours:@YES];
        [post setFollowing:@NO];
        [post setUuid:[Utility getUUID]];
        [post setIndex:[NSNumber numberWithInt:0]];

        //add profile pic if there exist one
        if( (!_photos || [_photos count] == 0)&& [_profileImageView image]){
            _photos = [[NSMutableArray alloc] init];
            [_photos addObject:[_profileImageView image]];
        }
        
        for (UIImage *image in _photos){
            // This will save NSData typed image to an external binary storage
            post.image = [NSData dataWithData:UIImagePNGRepresentation([self scaleAndRotateImage:image])];
//            post.image = [NSData dataWithData:UIImagePNGRepresentation(image)];

            MSDebug(@"Set post's image!");
            
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

        //Note that the completion block runs on main thread even if this method runs on non-main thread
        [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            MSDebug(@"Uploaded posts and stuff to server. Next upload the photo.");
            
            // Note that here the class of the value returned could be either NSMutableArray or Entity
            // We need to deal with them separtely
//            id value = [[mappingResult dictionary] valueForKey:@"Entity"];
//            NSArray *entities = nil;
//            if ([value isKindOfClass:[Entity class]]) {
//                entities = [NSArray arrayWithObject:value];
//            } else {
//                entities = [NSArray arrayWithArray:value];
//            }
//                
//            for (Entity *entity in entities) {
//                MSDebug(@"Entity to merge has remoteID: %@", entity.remoteID);
//                [entity updateUUIDinManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
//            }
            ASYNC({
                [Post setIndicesAsRefreshing:@[post]];
                [post uploadImageToS3];
            });
            
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
         */
        [objectManager enqueueObjectRequestOperation:operation];
//        if(_multiPostsTabBarController){
//            [_multiPostsTabBarController createPostsViewControllerWantsToSwitchAndScrollToPost:post];
//        }
        
    }
}

#pragma mark -
#pragma mark Image Helper Methods
- (UIImage *)scaleAndRotateImage:(UIImage *)image
{
    int kMaxResolution = 500;
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

#pragma mark -
#pragma mark Image Picker Controller Methods
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [Flurry endTimedEvent:@"Add_Photo" withParameters:@{FL_IS_FINISHED:FL_NO}];
    [[picker presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [Flurry endTimedEvent:@"Add_Photo" withParameters:@{FL_IS_FINISHED:FL_YES}];
    
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
-(void) fbFriendButtonPressed:(id)sender {
    
    if([_entities count] >= 6){
        [Utility generateAlertWithMessage:@"Sorry, your tags are full..." error:nil];
        return;
    }
    
    // FBSample logic
    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        MSDebug(@"no session");
        // if the session is closed, then we open it here, and establish a handler for state changes
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_birthday",@"friends_hometown",@"email",
                            @"friends_birthday",@"friends_location",@"friends_education_history",@"friends_work_history",                              nil];
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
    
    NSString *number = [NSString stringWithFormat:@"%u", [_entities count]];
    [Flurry logEvent:@"Add_FBFriends" withParameters:@{@"Existing_Entities":number} timed:YES];
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
}

# pragma mark -
#pragma mark - FBFriendPickerDelegate method
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    id<FBGraphUser> firstFrd = [self.friendPickerController.selection firstObject];
    _profilePicView.profileID = firstFrd.id;
    
    NSString *number = [NSString stringWithFormat:@"%u", [self.friendPickerController.selection count]];
    [Flurry endTimedEvent:@"Add_FBFriends" withParameters:@{@"Selected_Entities":number, FL_IS_FINISHED:FL_YES}];
    if([_entities count] + [self.friendPickerController.selection count] > 6){
        [Utility generateAlertWithMessage:@"Sorry, you can only tag 6 people..." error:nil];
    }
    [self setProfileImageViewWithfbUserID:firstFrd.id];
        for (id<FBGraphUser> frd in self.friendPickerController.selection) {
        _profilePicView.profileID = frd.id;
        [self processFBUser:frd];
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
    MSDebug(@"count %lu", [_entities count]);
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [Flurry endTimedEvent:@"Add_FBFriends" withParameters:@{FL_IS_FINISHED:FL_NO}];
    [self dismissViewControllerAnimated:YES completion:NULL];
}


# pragma mark -
#pragma mark - process every fb friend picked
- (void) processFBUser:(id<FBGraphUser>) frd{
    
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
    for(Entity *en in _entities){
        if([en.fbUserID isEqualToString:newFBEntity.fbUserID]){
            return;
        }
    }
    if([_entities count]<6){
        [_entities addObject:newFBEntity];
    } else{
        return;
    }
    [self reloadSelectedEntitiesSection];
    
    MSDebug(@"has found existing entity? %d", hasFoundExistingEntity);
    if(hasFoundExistingEntity){
        return;
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
                    if ([cityAndState count] > 1) {
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
            
            [self reloadSelectedEntitiesSection];
        }];

    }
}


# pragma mark -
#pragma mark - Handle selected entities
-(void)reloadSelectedEntitiesSection{
    NSUInteger entitiesCnt =[_entities count];
    if(entitiesCnt > 0){
        [self displayFirstRowEntities];
    } else{
        [self removeFirstRowEntities];
    }
    if(entitiesCnt > 2){
        [self displaySecondRowEntities];
    }else{
        [self removeSecondRowEntities];
    }
    if(entitiesCnt > 4){
        [self displayThirdRowEntities];
    } else{
        [self removeThirdRowEntities];
    }
    if(entitiesCnt == 0){
        CGFloat originalX = _textView.bounds.origin.x;
        CGFloat width = _textView.bounds.size.width;
        [_textView setFrame:CGRectMake(originalX+20, START_DISPLAYING_ENTITIES + 20, width, 100)];
        MSDebug(@"here!");
    } else if(entitiesCnt > 0 && entitiesCnt <= 2){
        CGFloat originalX = _textView.bounds.origin.x;
        CGFloat width = _textView.bounds.size.width;
        [_textView setFrame:CGRectMake(originalX+20, START_DISPLAYING_ENTITIES + HEIGHT_FOR_EACH_ENTITY_ROW + 20, width, 100)];
    } else if(entitiesCnt > 2 && entitiesCnt <= 4){
        CGFloat originalX = _textView.bounds.origin.x;
        CGFloat width = _textView.bounds.size.width;
        [_textView setFrame:CGRectMake(originalX+20, START_DISPLAYING_ENTITIES + 2*HEIGHT_FOR_EACH_ENTITY_ROW + 20, width, 100)];
    } else {
        CGFloat originalX = _textView.bounds.origin.x;
        CGFloat width = _textView.bounds.size.width;
        [_textView setFrame:CGRectMake(originalX+20, START_DISPLAYING_ENTITIES + 3*HEIGHT_FOR_EACH_ENTITY_ROW + 20, width, 100)];
    }
}
-(void) displayFirstRowEntities{
    if(!_whiteBackgroundRow1){
        _whiteBackgroundRow1 = [[UIView alloc] initWithFrame:CGRectMake(0, START_DISPLAYING_ENTITIES, WIDTH, HEIGHT_FOR_EACH_ENTITY_ROW)];
        [_whiteBackgroundRow1 setBackgroundColor:[UIColor whiteColor]];
    }
    [self.view addSubview:_whiteBackgroundRow1];
    
    if(!_verticalLineRow1){
        _verticalLineRow1 = [self drawLineFromPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES) toEndPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursLightPink]];
    }
    [self.view.layer addSublayer:_verticalLineRow1];
    
    if(!_horizontalLineRow1){
        _horizontalLineRow1 = [self drawLineFromPoint:CGPointMake(0, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW) toEndPoint:CGPointMake(WIDTH, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursDarkPink]];
    }
    [self.view.layer addSublayer:_horizontalLineRow1];
    
    UILabel *tempInstiLabel;
    [_nameButton1 removeFromSuperview];
    [_instiLabel1 removeFromSuperview];
    _nameButton1 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:0] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES andY:START_DISPLAYING_ENTITIES+OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
    _instiLabel1 = tempInstiLabel;
    [_nameButton1 setTag:1];
    [_nameButton1 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nameButton1];
    [self.view addSubview:_instiLabel1];
    
    if(!_deleteButton1){
        _deleteButton1 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+OFFSET_Y_FOR_DISPLAY_ENTITIES];
        _deleteButton1.tag = 1;
        [_deleteButton1 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_deleteButton1];
    
    if ([_entities count] > 1) {
        UILabel *tempInstiLabel;
        [_nameButton2 removeFromSuperview];
        [_instiLabel2 removeFromSuperview];
        _nameButton2 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:1] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 andY:START_DISPLAYING_ENTITIES+OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
        _instiLabel2 = tempInstiLabel;
        [_nameButton2 setTag:2];
        [_nameButton2 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nameButton2];
        [self.view addSubview:_instiLabel2];
        if(!_deleteButton2){
            _deleteButton2 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+OFFSET_Y_FOR_DISPLAY_ENTITIES];
            _deleteButton2.tag = 2;
            [_deleteButton2 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

        }
        [self.view addSubview:_deleteButton2];
    }
}
-(void) displaySecondRowEntities{
    if(!_whiteBackgroundRow2){
        _whiteBackgroundRow2 = [[UIView alloc] initWithFrame:CGRectMake(0, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW, WIDTH, HEIGHT_FOR_EACH_ENTITY_ROW)];
        [_whiteBackgroundRow2 setBackgroundColor:[UIColor whiteColor]];
    }
    [self.view addSubview:_whiteBackgroundRow2];
    
    if(!_verticalLineRow2){
        _verticalLineRow2 = [self drawLineFromPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW) toEndPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursLightPink]];
    }
    [self.view.layer addSublayer:_verticalLineRow2];
    
    if(!_horizontalLineRow2){
        _horizontalLineRow2 = [self drawLineFromPoint:CGPointMake(0, START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW*2) toEndPoint:CGPointMake(WIDTH, START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursDarkPink]];
    }
    [self.view.layer addSublayer:_horizontalLineRow2];
    
    UILabel *tempInstiLabel;
    [_nameButton3 removeFromSuperview];
    [_instiLabel3 removeFromSuperview];
    _nameButton3 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:2] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES andY:START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW+OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
    _instiLabel3 = tempInstiLabel;
    [_nameButton3 setTag:3];
    [_nameButton3 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nameButton3];
    [self.view addSubview:_instiLabel3];
    if(!_deleteButton3){
        _deleteButton3 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW+OFFSET_Y_FOR_DISPLAY_ENTITIES];
        _deleteButton3.tag = 3;
        [_deleteButton3 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_deleteButton3];
    
    if ([_entities count] > 3) {
        UILabel *tempInstiLabel;
        [_nameButton4 removeFromSuperview];
        [_instiLabel4 removeFromSuperview];
        _nameButton4 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:3] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 andY:START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW+OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
        _instiLabel4 = tempInstiLabel;
        [_nameButton4 setTag:4];
        [_nameButton4 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nameButton4];
        [self.view addSubview:_instiLabel4];
        if(!_deleteButton4){
            _deleteButton4 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+HEIGHT_FOR_EACH_ENTITY_ROW+OFFSET_Y_FOR_DISPLAY_ENTITIES];
            _deleteButton4.tag = 4;
            [_deleteButton4 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:_deleteButton4];
    }
}
-(void) displayThirdRowEntities{
    if(!_whiteBackgroundRow3){
        _whiteBackgroundRow3 = [[UIView alloc] initWithFrame:CGRectMake(0, START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW, WIDTH, HEIGHT_FOR_EACH_ENTITY_ROW)];
        [_whiteBackgroundRow3 setBackgroundColor:[UIColor whiteColor]];
    }
    [self.view addSubview:_whiteBackgroundRow3];

    
    if(!_verticalLineRow3){
        _verticalLineRow3 = [self drawLineFromPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW) toEndPoint:CGPointMake(WIDTH/2, START_DISPLAYING_ENTITIES+3*HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursLightPink]];
    }
    [self.view.layer addSublayer:_verticalLineRow3];
    
    if(!_horizontalLineRow3){
        _horizontalLineRow3 = [self drawLineFromPoint:CGPointMake(0, START_DISPLAYING_ENTITIES+3*HEIGHT_FOR_EACH_ENTITY_ROW) toEndPoint:CGPointMake(WIDTH, START_DISPLAYING_ENTITIES+3*HEIGHT_FOR_EACH_ENTITY_ROW) withColor:[UIColor colorForYoursDarkPink]];
    }
    [self.view.layer addSublayer:_horizontalLineRow3];
    
    UILabel *tempInstiLabel;
    [_nameButton5 removeFromSuperview];
    [_instiLabel5 removeFromSuperview];
    _nameButton5 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:4] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES andY:START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW +OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
    _instiLabel5 = tempInstiLabel;
    [_nameButton5 setTag:5];
    [_nameButton5 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_nameButton5];
    [self.view addSubview:_instiLabel5];
    if(!_deleteButton5){
        _deleteButton5 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW +OFFSET_Y_FOR_DISPLAY_ENTITIES];
        _deleteButton5.tag = 5;
        [_deleteButton5 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.view addSubview:_deleteButton5];
    if ([_entities count] > 5) {
        [_nameButton6 removeFromSuperview];
        [_instiLabel6 removeFromSuperview];
        UILabel *tempInstiLabel;
        _nameButton6 = [self getEntityNameAndInstitutionForEntity:[_entities objectAtIndex:5] AtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 andY:START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW +OFFSET_Y_FOR_DISPLAY_ENTITIES returnInstiLabel:&tempInstiLabel];
        _instiLabel6 = tempInstiLabel;
        [_nameButton6 setTag:6];
        [_nameButton6 addTarget:self action:@selector(nameButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_nameButton6];
        [self.view addSubview:_instiLabel6];
        if(!_deleteButton6){
            _deleteButton6 = [self createDeleteButtonAtX:OFFSET_X_FOR_DISPLAY_ENTITIES + WIDTH/2 + DELETE_BUTTON_OFFSET_X andY:START_DISPLAYING_ENTITIES+2*HEIGHT_FOR_EACH_ENTITY_ROW +OFFSET_Y_FOR_DISPLAY_ENTITIES];
            _deleteButton6.tag = 6;
            [_deleteButton6 addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.view addSubview:_deleteButton6];

    }
}

-(void) removeFirstRowEntities{
    [_horizontalLineRow1 removeFromSuperlayer];
    [_verticalLineRow1 removeFromSuperlayer];
    [_nameButton1 removeFromSuperview];
    [_nameButton2 removeFromSuperview];
    [_instiLabel1 removeFromSuperview];
    [_instiLabel2 removeFromSuperview];
    [_whiteBackgroundRow1 removeFromSuperview];
    [_deleteButton1 removeFromSuperview];
    [_deleteButton2 removeFromSuperview];
}
-(void) removeSecondRowEntities{
    [_horizontalLineRow2 removeFromSuperlayer];
    [_verticalLineRow2 removeFromSuperlayer];
    [_nameButton3 removeFromSuperview];
    [_nameButton4 removeFromSuperview];
    [_instiLabel3 removeFromSuperview];
    [_instiLabel4 removeFromSuperview];
    [_whiteBackgroundRow2 removeFromSuperview];
    [_deleteButton3 removeFromSuperview];
    [_deleteButton4 removeFromSuperview];
}
-(void) removeThirdRowEntities{
    [_horizontalLineRow3 removeFromSuperlayer];
    [_verticalLineRow3 removeFromSuperlayer];
    [_nameButton5 removeFromSuperview];
    [_nameButton6 removeFromSuperview];
    [_instiLabel5 removeFromSuperview];
    [_instiLabel6 removeFromSuperview];
    [_whiteBackgroundRow3 removeFromSuperview];
    [_deleteButton5 removeFromSuperview];
    [_deleteButton6 removeFromSuperview];
}

-(UIButton *) getEntityNameAndInstitutionForEntity:(Entity *)entity AtX:(CGFloat)originX andY:(CGFloat)originY returnInstiLabel:(UILabel **)instiLabel{
    UIButton *nameButton = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY-10, WIDTH/2, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT)];
    NSAttributedString *nameWithFont;
    if([[entity name] length] > 16){
        NSString *stringName = [[[entity name] substringWithRange:NSMakeRange(0, 15)] stringByAppendingString:@"..."];
        nameWithFont = [[NSAttributedString alloc] initWithString:stringName attributes:[Utility getCreatePostDisplayEntityFontDictionary]];
    }else{
        nameWithFont = [[NSAttributedString alloc] initWithString:[entity name] attributes:[Utility getCreatePostDisplayEntityFontDictionary]];
    }
    [nameButton setAttributedTitle:nameWithFont forState:UIControlStateNormal];
    nameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    if(entity.institution){
        *instiLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY+13, WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT*2/3)];
        NSAttributedString *instiWithFont;
        if([entity.institution length] > 25){
            NSString *stringInstitution = [[entity.institution substringWithRange:NSMakeRange(0, 24)] stringByAppendingString:@"..."];
            instiWithFont = [[NSAttributedString alloc] initWithString:stringInstitution attributes:[Utility getCreatePostDisplayInstitutionFontDictionary]];
        }else{
            instiWithFont = [[NSAttributedString alloc] initWithString:entity.institution attributes:[Utility getCreatePostDisplayInstitutionFontDictionary]];
        }
        [*instiLabel setAttributedText:instiWithFont];
        
    }
    return nameButton;
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

# pragma mark -
#pragma mark - Draw Line
-(CAShapeLayer *) drawLineFromPoint:(CGPoint)startPoint toEndPoint:(CGPoint)endPoint withColor:(UIColor *)color{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0f);
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = color.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    return dashLineLayer;
}

# pragma mark -
#pragma mark - create Button
-(UIButton *) createDeleteButtonAtX:(CGFloat)originX andY:(CGFloat)originY{
    UIImage *btnImage = [UIImage imageNamed:@"icon-name_delete.png"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(originX, originY, btnImage.size.width, btnImage.size.height)];
    [button setImage:btnImage forState:UIControlStateNormal];
    return button;
}

# pragma mark -
#pragma mark - Helper Methods
-(void)setProfileImageViewWithfbUserID:(NSString *)fbUserID{
    if(fbUserID == nil){
        [_profileImageView setImage:[UIImage imageNamed:@"background.png"]];
        [_addPhotoButton setAlpha:1];
        return;
    }
    [_profileImageView setBackgroundColor:[UIColor colorForYoursWhite]];
    NSString *imageUrl = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", fbUserID];
    _currentDisplayFBID = fbUserID;
    [_profileImageView setImageWithURL:[NSURL URLWithString:imageUrl]];
    _profileImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_addPhotoButton setAlpha:0.6];
}


@end
