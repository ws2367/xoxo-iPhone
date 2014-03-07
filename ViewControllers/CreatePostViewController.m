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

@interface CreatePostViewController ()
{
    int photoIndex;
    UIImageView *currImageView;
    UIImageView *leftImageView; //not used
    UIImageView *rightImageView; //not used
}
@property (weak, nonatomic) IBOutlet UITextView *textView;

// for image picker controller
@property (weak, nonatomic) IBOutlet UIView *superImageView;
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

@end


@implementation CreatePostViewController


- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _masterViewController = viewController;// Custom initialization
        _entities = [[NSMutableArray alloc] init];
    }
    
    return self;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    [_superImageView addGestureRecognizer:[[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(swipeImage:)]];
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]
                                            initWithTarget:self
                                            action:@selector(swipeImage:)];
    
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_superImageView addGestureRecognizer:recognizer];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Input Accessory View Methods

-(UIView *)createInputAccessoryView{
    
    // Note that the frame width (third value in the CGRectMake method)
    // should change accordingly in landscape orientation.
    UIView *res = [[UIView alloc] initWithFrame:CGRectMake(0.0,
                                                           0.0,
                                                           self.view.frame.size.width,
                                                           35.0)];
    
    [res setBackgroundColor:[[UIColor lightGrayColor] colorWithAlphaComponent:0.3]];
    
    UIButton *doneButton = [UIButton buttonWithType: UIButtonTypeRoundedRect];
    
    [doneButton setFrame: CGRectMake((self.view.frame.size.width - 60.0), 0.0, 50.0, 35.0)];
    
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
- (IBAction)addEntity:(id)sender {
    [_content setString:_textView.text];
    
    _addEntityController =
    [[CreateEntityViewController alloc] initWithCreatePostViewController:self];
    
    _addEntityController.view.frame = CGRectMake(0,
                                                   self.view.frame.size.height,
                                                   self.view.frame.size.width,
                                                   self.view.frame.size.height);
    
    
    [self.view addSubview:_addEntityController.view];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _addEntityController.view.frame = CGRectMake(0,
                                                                      0,
                                                                      self.view.frame.size.width,
                                                                      self.view.frame.size.height);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    

    NSLog(@"Start adding more entities bah!");
}

- (IBAction)addPost:(id)sender {
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];
    
    Post *post =[NSEntityDescription insertNewObjectForEntityForName:@"Post"
                                              inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];

    if (post != nil) {
        
        post.content = _textView.text;
        
        //set up relationship with entities
        [post setEntities:[NSSet setWithArray:_entities]];
        
        // this is for the server!
        [post setEntitiesUUIDs:[NSArray arrayWithArray:[[post.entities allObjects] valueForKey:@"uuid"]]];
        
        NSLog(@"%@", post.entitiesUUIDs);
        [post setDirty:@YES];
        [post setDeleted:@NO];
        [post setUuid:[Utility getUUID]];
                
        //add photos to post
        // In _photos are UIImage objects
        for (UIImage *image in _photos){
            Photo *photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
            
            // This will save NSData typed image to an external binary storage
            photo.image = UIImagePNGRepresentation(image);
            [photo setDirty:@YES];// dirty is a NSNumber so @YES is a literal in Obj C that is created for this purpose. [NSNumber numberWithBool:] works too.
            [photo setDeleted:@NO];
            [photo setUuid:[Utility getUUID]];
            
            [post addPhotosObject:photo];
        }

        // send the institutions, entities and the post to the server!
        RKObjectManager *objectManager = [RKObjectManager sharedManager];
        

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
        
        NSMutableArray *operations = [[NSMutableArray alloc] init];
        
        RKManagedObjectRequestOperation *institutionsPOSTOperation = nil;
        RKManagedObjectRequestOperation *entitiesPOSTOperation = nil;
        if ([institutionsObjects count] > 0) {
            institutionsPOSTOperation = [objectManager appropriateObjectRequestOperationWithObject:institutionsObjects
                                                                                            method:RKRequestMethodPOST
                                                                                              path:@"institutions"
                                                                                        parameters:nil];
            [operations addObject:institutionsPOSTOperation];
        }
        
        if ([entitiesObjects count] > 0) {
            entitiesPOSTOperation = [objectManager appropriateObjectRequestOperationWithObject:entitiesObjects
                                                                                        method:RKRequestMethodPOST
                                                                                          path:@"entities"
                                                                                    parameters:nil];
            if (institutionsPOSTOperation != nil) [entitiesPOSTOperation addDependency:institutionsPOSTOperation];
            [operations addObject:entitiesPOSTOperation];
        }
        
        RKManagedObjectRequestOperation *postPOSTOperation =
        [objectManager appropriateObjectRequestOperationWithObject:post
                                                            method:RKRequestMethodPOST
                                                              path:nil
                                                        parameters:nil];
        
        if (entitiesPOSTOperation != nil) [postPOSTOperation addDependency:entitiesPOSTOperation];
        [operations addObject:postPOSTOperation];
        
        [objectManager enqueueBatchOfObjectRequestOperations:operations progress:nil completion:^(NSArray *operations) {
            
            // Yeahhh, they are clean again!
            [institutionsObjects setValue:@NO forKey:@"dirty"];
            [entitiesObjects setValue:@NO forKey:@"dirty"];
            [post setDirty:@NO]; // you are clean, post!
            
            // then we can save all the stuff to database
            NSError *SavingErr = nil;
            if ([managedObjectStore.mainQueueManagedObjectContext saveToPersistentStore:&SavingErr]) {
                NSLog(@"Successfully saved the post!");
            } else {
                NSLog(@"Failed to save the managed object context.");
            }
        }];
        
        [_masterViewController finishCreatingPostBackToHomePage];
    }
}

- (IBAction)goBack:(id)sender {
    [_entities removeAllObjects];
    [_masterViewController cancelCreatingPost];
}

- (IBAction)addPhoto:(id)sender {
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    [self presentViewController:_picker animated:YES completion:nil];
}


- (void) finishAddingEntity {
    Entity *entity = _addEntityController.selectedEntity;
    
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    
    [_entities addObject:entity];
    
    _entityNames = [NSMutableString string];
    
    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        if (ent != [_entities lastObject])
            [_entityNames appendString:@", "];
    }
    
    self.entitiesTextField.text = (NSString *)_entityNames;
    
    self.view.frame = CGRectMake(0,
                                 self.view.frame.size.height,
                                 self.view.frame.size.width,
                                 self.view.frame.size.height);
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame = CGRectMake(0,
                                                      0,
                                                      self.view.frame.size.width,
                                                      self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
    
    
    [_addEntityController.view removeFromSuperview];
    
    //    [self.view addSubview:createPostController.view];
}



#pragma mark -
#pragma mark Image Picker Controller Methods

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picked presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
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
}




#pragma mark -
#pragma mark Gesture Controller Method

// TODO: change this to provide better user experience - the moving image should follow the swipe closely
- (void)swipeImage:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Get the right swipe");
        if (photoIndex > 0) {
            photoIndex = photoIndex - 1;
            
            UIImageView *iv =
            [[UIImageView alloc]
                initWithFrame:CGRectMake(
                                        -(_superImageView.frame.size.width),
                                        _superImageView.frame.origin.y,
                                        _superImageView.frame.size.width,
                                        _superImageView.frame.size.height)];
            
            [iv setImage:[_photos objectAtIndex:photoIndex]];
            [self.view addSubview:iv];
            
            [UIView animateWithDuration:ANIMATION_DURATION
                                  delay:ANIMATION_DELAY
                                options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                             animations:^{
                                 iv.frame =
                                 CGRectMake(0,
                                            _superImageView.frame.origin.y,
                                            _superImageView.frame.size.width,
                                            _superImageView.frame.size.height);
                                 
                                 currImageView.frame =
                                 CGRectMake(_superImageView.frame.size.width,
                                            _superImageView.frame.origin.y,
                                            _superImageView.frame.size.width,
                                            _superImageView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [currImageView removeFromSuperview];
                                 currImageView = iv;
                             }
             ];
        }
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        // You cannot compare NSInteger with int directly!!!
        if (photoIndex < (int)([_photos count] - 1)) {
            photoIndex = photoIndex + 1;

            UIImageView *iv =
            [[UIImageView alloc]
             initWithFrame:CGRectMake(
                                      _superImageView.frame.size.width,
                                      _superImageView.frame.origin.y,
                                      _superImageView.frame.size.width,
                                      _superImageView.frame.size.height)];
            
            [iv setImage:[_photos objectAtIndex:photoIndex]];
            [self.view addSubview:iv];
            
            [UIView animateWithDuration:ANIMATION_DURATION
                                  delay:ANIMATION_DELAY
                                options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                             animations:^{
                                 iv.frame =
                                 CGRectMake(0,
                                            _superImageView.frame.origin.y,
                                            _superImageView.frame.size.width,
                                            _superImageView.frame.size.height);
                                 
                                 currImageView.frame =
                                 CGRectMake(-_superImageView.frame.size.width,
                                            _superImageView.frame.origin.y,
                                            _superImageView.frame.size.width,
                                            _superImageView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [currImageView removeFromSuperview];
                                 currImageView = iv;
                             }
             ];
        }
    }
}

# pragma mark -
# pragma mark RestKit Methods
- (BOOL) updatePost:(Post *)post {
    
    
    [[RKObjectManager sharedManager] postObject:@[post] path:@"/posts" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        NSLog(@"update succeeded.");
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"update failed.");
    }];
    return YES;
}
/*
- (IBAction)swiped:(id)sender {
    [_masterViewController finishCreatingPostBackToHomePage];
}
*/


//#pragma mark -
//#pragma mark TextField Delegate

//-(BOOL) textFieldShouldReturn:(UITextField*) textField {
//    [textField resignFirstResponder];
//    return YES;
//}
@end
