//
//  CreatePostViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreatePostViewController.h"
#import "CreateEntityViewController.h"
#import "ViewMultiPostsVC.h"
#import "Entity.h"
#import <QuartzCore/QuartzCore.h>
#import "ServerConnector.h"

@interface CreatePostViewController ()
{
    int photoIndex;
    UIImageView *currImageView;
    UIImageView *leftImageView;
    UIImageView *rightImageView;
}
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIView *PostSuperImageView;

@property (nonatomic, retain) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet UITextField *entitiesTextField;
@property (strong, nonatomic) NSMutableString *entityNames;

@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableString *content;

@property (weak, nonatomic) ViewMultiPostsVC *viewMultiPostsVC;
@property (strong, nonatomic) CreateEntityViewController *addEntityController;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@end

#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0


@implementation CreatePostViewController


- (id)initWithViewMultiPostsVC:(ViewMultiPostsVC *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsVC = viewController;// Custom initialization
        _entities = [[NSMutableArray alloc] init];
    }
    NSLog(@"hello?");
    
    return self;
}


#pragma mark -
#pragma mark TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *) textView
{
    
    if ([_textView.text isEqualToString:@"Type the content here..."]) {
        [_textView setText:@""];
        [_textView setTextColor:[UIColor blackColor]];
    }
    
    
    /*
    [_backButton removeTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventAllEvents];

    [_backButton setTitle:@"Done" forState:UIControlStateNormal];
    [_backButton addTarget:self
                   action:@selector(doneEditing:)
         forControlEvents:UIControlEventTouchUpInside];
    
    _postButton.hidden = true;*/
}



#pragma mark -
#pragma mark Button method
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

    [doneButton addTarget: self action: @selector(doneEditing:) forControlEvents: UIControlEventTouchUpInside];
  
    [res addSubview:doneButton];
    
    return res;
}

- (IBAction)addEntityPressed:(id)sender {
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
    
    

    NSLog(@"Start adding Entity bah!");
}

- (void) finishAddingEntity {
    Entity *person = _addEntityController.selectedEntity;
    
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    
    [_entities addObject:person];
    
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

- (IBAction)doneEditing:(id)sender {
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

- (IBAction)postButtonPressed:(id)sender {
    [_viewMultiPostsVC finishCreatingPostBackToHomePage];
}

- (IBAction)backButtonPressed:(id)sender {
    [_entities removeAllObjects];
    [_viewMultiPostsVC cancelCreatingPost];
}

- (IBAction)pickImageButtonPressed:(id)sender {
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    _picker.allowsEditing = NO;
    [self presentViewController:_picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picked presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
    [_photos addObject:[info objectForKey:UIImagePickerControllerOriginalImage]];
    photoIndex = (int)[_photos count] - 1;
    
    [currImageView removeFromSuperview];
    
    currImageView =
    [[UIImageView alloc]
     initWithFrame:CGRectMake(0,
                              _PostSuperImageView.frame.origin.y,
                              _PostSuperImageView.frame.size.width-10,
                              _PostSuperImageView.frame.size.height)];
    
    [currImageView setImage:[_photos objectAtIndex:photoIndex]];
    
    [self.view addSubview:currImageView];
}




#pragma mark -
#pragma mark Gesture Controller Method


- (void)swipeImage:(UISwipeGestureRecognizer *)gesture
{
    if (gesture.direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"Get the right swipe");
        if (photoIndex > 0) {
            photoIndex = photoIndex - 1;
            
            UIImageView *iv =
            [[UIImageView alloc]
                initWithFrame:CGRectMake(
                                        -(_PostSuperImageView.frame.size.width),
                                        _PostSuperImageView.frame.origin.y,
                                        _PostSuperImageView.frame.size.width,
                                        _PostSuperImageView.frame.size.height)];
            
            [iv setImage:[_photos objectAtIndex:photoIndex]];
            [self.view addSubview:iv];
            
            [UIView animateWithDuration:ANIMATION_DURATION
                                  delay:ANIMATION_DELAY
                                options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                             animations:^{
                                 iv.frame =
                                 CGRectMake(0,
                                            _PostSuperImageView.frame.origin.y,
                                            _PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.size.height);
                                 
                                 currImageView.frame =
                                 CGRectMake(_PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.origin.y,
                                            _PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [currImageView removeFromSuperview];
                                 currImageView = iv;
                             }];
            
            
            
        }
        
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        // You cannot compare NSInteger to int directly!!!
        if (photoIndex < (int)([_photos count] - 1)) {
            photoIndex = photoIndex + 1;

            UIImageView *iv =
            [[UIImageView alloc]
             initWithFrame:CGRectMake(
                                      (_PostSuperImageView.frame.size.width),
                                      _PostSuperImageView.frame.origin.y,
                                      _PostSuperImageView.frame.size.width,
                                      _PostSuperImageView.frame.size.height)];
            
            [iv setImage:[_photos objectAtIndex:photoIndex]];
            [self.view addSubview:iv];
            
            [UIView animateWithDuration:ANIMATION_DURATION
                                  delay:ANIMATION_DELAY
                                options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                             animations:^{
                                 iv.frame =
                                 CGRectMake(0,
                                            _PostSuperImageView.frame.origin.y,
                                            _PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.size.height);
                                 
                                 currImageView.frame =
                                 CGRectMake(-_PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.origin.y,
                                            _PostSuperImageView.frame.size.width,
                                            _PostSuperImageView.frame.size.height);
                             }
                             completion:^(BOOL finished){
                                 [currImageView removeFromSuperview];
                                 currImageView = iv;
                             }];
            
            

        }
    }
    
}- (IBAction)swiped:(id)sender {
    [_viewMultiPostsVC finishCreatingPostBackToHomePage];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}



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
    int cnt = [_entities count];
    NSLog(@"In CreatPostViewController, count = %d", cnt);

    [_PostSuperImageView addGestureRecognizer:[[UISwipeGestureRecognizer alloc]
                                               initWithTarget:self
                                               action:@selector(swipeImage:)]];
     
     UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc]
                                             initWithTarget:self
                                             action:@selector(swipeImage:)];
    
    recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [_PostSuperImageView addGestureRecognizer:recognizer];
    
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
#pragma mark TextField Delegate

//-(BOOL) textFieldShouldReturn:(UITextField*) textField {
//    [textField resignFirstResponder];
//    return YES;
//}

#pragma mark -
#pragma mark Test Function
- (void)receiveNSArray:(NSArray *)result{
    NSLog(@"CreatePostViewController receive %@", result);
}



@end
