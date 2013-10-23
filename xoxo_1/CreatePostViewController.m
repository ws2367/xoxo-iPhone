//
//  CreatePostViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreatePostViewController.h"
#import "BIDViewController.h"
#import "Entity.h"
#import <QuartzCore/QuartzCore.h>

@interface CreatePostViewController ()

@property (weak, nonatomic) BIDViewController *bidViewController;

@end


#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0
#define ROW_HEIGHT 220


@implementation CreatePostViewController


- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
        _entities = [[NSMutableArray alloc] init];
    }
    
    return self;
}

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
            
            [self.view addSubview:iv];
            
        }
        
    } else if (gesture.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        if (photoIndex < (int)([_photos count]- 1)) {
            photoIndex = photoIndex + 1;

            UIImageView *iv =
            [[UIImageView alloc]
             initWithFrame:CGRectMake(
                                      (_PostSuperImageView.frame.size.width),
                                      _PostSuperImageView.frame.origin.y,
                                      _PostSuperImageView.frame.size.width,
                                      _PostSuperImageView.frame.size.height)];
            
            [iv setImage:[_photos objectAtIndex:photoIndex]];
            
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
            
            [self.view addSubview:iv];

        }
    }
    
}

- (IBAction)swiped:(id)sender {
    [_bidViewController finishCreatingPostBackToHomePage];
}

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (IBAction)postButtonPressed:(id)sender {
    [_bidViewController finishCreatingPostBackToHomePage];
}
- (IBAction)backButtonPressed:(id)sender {
    [_bidViewController cancelCreatingPost];
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
    //currImageView = iv;
    
    //[_photo setImage:[_photos objectAtIndex:photoIndex]];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
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

    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        [_entityNames appendString:@", "];
     }
    NSLog((NSString *)_entityNames);
    
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

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

@end
