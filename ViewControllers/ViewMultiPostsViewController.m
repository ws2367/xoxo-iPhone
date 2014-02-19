//
//  ViewMultiPostsViewController.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewMultiPostsViewController.h"
#import "BigPostTableViewCell.h"
#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "UserMenuViewController.h"
#import "MultiPostsTableViewController.h"
#import "Post.h"

@interface ViewMultiPostsViewController ()


@property (strong, nonatomic) UIView *blackMaskOnTopOfView;

// children view controllers
@property (strong, nonatomic) CreateEntityViewController *createEntityController;
@property (strong, nonatomic) CreatePostViewController *createPostController;
@property (strong, nonatomic) ViewPostViewController *viewPostViewController;
@property (strong, nonatomic) ViewEntityViewController *viewEntityViewController;
@property (strong, nonatomic) UserMenuViewController *userMenuViewController;

// segmented controller
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

// try adding a table view controller and UIRefreshControl
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MultiPostsTableViewController *tableViewController;

@end

#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0



@implementation ViewMultiPostsViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[tableView registerClass:[BIDNameAndColorCell class]
    
    //add a table view 
    _tableViewController = [[MultiPostsTableViewController alloc] init];
    _tableViewController.tableView = _tableView;
    _tableViewController.masterController = self;
    _tableViewController.managedObjectContext = self.managedObjectContext;
    _tableView.delegate = _tableViewController;
    [_tableViewController setup];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Segmented Control Methods

- (IBAction)changeSegment:(id)sender {
    NSInteger selectedIdx = [sender selectedSegmentIndex];

    //TODO: signal tableViewController to change content
    /*
    NSDictionary *data;
    NSString *numPosts = [NSString stringWithFormat:@"%d",[self.posts count] + POSTS_INCREMENT_NUM];
    if(selectedIdx == 0){
        
        
        //send out request
        data = @{@"num" : numPosts, @"sortby" : @"popularity"};
        //NSLog(@"To download %@ posts.", numPosts);
        
        NSLog(@"data I sent: %@", data);
        
        [_serverConnector sendJSONGetJSONArray:data];
        
    }
    else if(selectedIdx == 1){
        data = @{@"num" : numPosts, @"sortby" : @"recent"};
        //NSLog(@"To download %@ posts.", numPosts);
        
        NSLog(@"data I sent: %@", data);

        
        [_serverConnector sendJSONGetJSONArray:data];

    }
    else{
        data = @{@"num" : numPosts, @"sortby" : @"nearby"};
        //NSLog(@"To download %@ posts.", numPosts);
        
        
    }
    [_serverConnector sendJSONGetJSONArray:data];*/
    
}

#pragma mark -
#pragma mark Switch View Methods

//TODO: combine all view controller switching functions if possible
- (void)cancelCreatingEntity{
    // black mask is to disable all buttons on the view so that users don't double click any button
    [_blackMaskOnTopOfView removeFromSuperview];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createEntityController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         //_toCreateEntityToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         //_notHereButton.frame = CGRectMake(100, HEIGHT + 422, 100, 44);
                        //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                         [_createEntityController.view removeFromSuperview];
                     }];
    //make the keyboard invisible
    [_createEntityController.view endEditing:YES];
    
}

- (void)cancelCreatingPost{
    // creatingPostViewController is on top of creatingEntityController so the black mask we want to dismiss belongs to creatingEntityControllerss
    // TODO: it is possible and preferrable that black masks are all controlled by BIDVewController
    [_createEntityController dismissBlackMask];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);

                     }
                     completion:^(BOOL finished){
                         [_createPostController.view removeFromSuperview];
                     }];
    
    [_createPostController.view endEditing:YES];
 
    
}

- (void)cancelViewingPost{
    
    [_blackMaskOnTopOfView removeFromSuperview];

    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                         [_viewPostViewController.view removeFromSuperview];
                     }];
        
    
}

- (void)cancelViewingEntity{
    
    [_blackMaskOnTopOfView removeFromSuperview];

    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewEntityViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                         [_viewEntityViewController.view removeFromSuperview];
                     }];
    
    
}


- (void)finishCreatingPostBackToHomePage{
    [_createEntityController dismissBlackMask];
    
    [_blackMaskOnTopOfView removeFromSuperview];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         
                         //_toCreatePostToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         _createEntityController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         //_toCreateEntityToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         //_notHereButton.frame = CGRectMake(100, HEIGHT + 422, 100, 44);
                         //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                         [_createPostController.view removeFromSuperview];
                         _entities = nil;
                         
                     }];
    
    [_createPostController.view endEditing:YES];
    
    //[self.postController.view removeFromSuperview];
    //[self.postToolbar removeFromSuperview];
    //[self.view insertSubview:self.myTableView atIndex:2];
    
    
    
    
}


- (void)finishCreatingEntityStartCreatingPost{
    Entity *person = _createEntityController.selectedEntity;
    
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    

    [_entities addObject:person];
    
    //_toCreatePostToolbar = [self createPostToolbarForEntity:false];
    _createPostController = [[CreatePostViewController alloc] initWithViewMultiPostsViewController:self];
    self.createPostController.entities = _entities;
    _createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createPostController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                         //_toCreatePostToolbar.frame = CGRectMake(0, 22, WIDTH, 44);
                         //[self.myTableView setAlpha:0];
                         //self.view.backgroundColor = [UIColor whiteColor];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:self.createPostController.view];
    //[self.view addSubview:_toCreatePostToolbar];

}

// TODO: The viewPostViewController should handle a Post object passed by the sender
- (void)startViewingPostForPost:(Post *)post {
    [self allocateBlackMask];
    
    _viewPostViewController = [[ViewPostViewController alloc] initWithViewMultiPostsViewController:self];
    
    _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    _viewPostViewController.pic = @"pic1";
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewPostViewController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:_viewPostViewController.view];

    
    
}

- (IBAction)startCreatingEntity:(id)sender {
    
    [self allocateBlackMask];
    
    if(_createEntityController == nil){
        _createEntityController =[[CreateEntityViewController alloc] initWithViewMultiPostsViewController:self];
    }
    

    
    //UIBarButtonItem *space = [[UIBarButtonItem alloc] ini

    //_toCreateEntityToolbar = [self createPostToolbarForEntity:true];
    //_notHereButton = [self createNotHereButton];
     _createEntityController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    
    [self.view addSubview:_createEntityController.view];

    /*
    [UIView setAnimationTransition:
    UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    */
     
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createEntityController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);

                         }
                     completion:^(BOOL finished){
                     }];

    //[self.view insertSubview:self.postController.view atIndex:1];



}

- (void)cancelUserMenu{
    [_userMenuViewController.view endEditing:YES];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _userMenuViewController.view.frame = CGRectMake(-WIDTH, 0, WIDTH, HEIGHT);
                         [_blackMaskOnTopOfView setAlpha:0];
                         
                     }
                     completion:^(BOOL finished){
                         [_blackMaskOnTopOfView removeFromSuperview];

                     }];
    
    
}

-(void)sharePost{
    ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    
    /*picker.view.frame = CGRectMake( WIDTH, 0, WIDTH, HEIGHT);
    [self.view addSubview:picker.view];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         picker.view.frame = CGRectMake( 0, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];*/
    
    
    [self presentViewController:picker animated:YES completion:nil];
    
    
    
    //CFErrorRef error = nil;
    //ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error); // indirection
    //if (!addressBook) // test the result, not the error
    //{
    //    NSLog(@"ERROR!!!");
    //    return; // bail
    //}
    //CFArrayRef arrayOfPeople = ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    //NSLog(@"%@", arrayOfPeople);
}


- (void) startViewingEntityForEntity:(Entity *)entity
{
    [self allocateBlackMask];
    _viewEntityViewController = [[ViewEntityViewController alloc] initWithViewMultiPostsViewController:self];
    
    _viewEntityViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);

    //This should be handling the Entity object
    [_viewEntityViewController setEntityName:@"Iru Wang"];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewEntityViewController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    
    //[self.view insertSubview:self.postController.view atIndex:1];
    [self.view addSubview:_viewEntityViewController.view];

    
}


- (IBAction) createPost:(id)sender{
    
    _createPostController = [[CreatePostViewController alloc] initWithViewMultiPostsViewController:self];
    self.createPostController.entities = [[NSMutableArray alloc] init];
    _createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createPostController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:self.createPostController.view];

}


#pragma mark -
#pragma mark Button Methods
- (IBAction)userMenuButtonPressed:(id)sender {
    
    [self allocateBlackMask];
    UITapGestureRecognizer *tapBIDView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelUserMenu)];
    [_blackMaskOnTopOfView addGestureRecognizer:tapBIDView];
    
    
    
    _userMenuViewController = [[UserMenuViewController alloc] initWithViewMultiPostsViewController:self];
    
    _userMenuViewController.view.frame = CGRectMake( -WIDTH, 0, WIDTH, HEIGHT);
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _userMenuViewController.view.frame = CGRectMake(-WIDTH/2, 0, WIDTH, HEIGHT);
                         [_blackMaskOnTopOfView setAlpha:0.6];
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    
    //[self.view insertSubview:self.postController.view atIndex:1];
    [self.view addSubview:_userMenuViewController.view];
    
    
}



#pragma mark -
#pragma mark Rearrange View Methods

- (void)beginSearchTakeOverWindow{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _userMenuViewController.view.frame = self.view.bounds;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)endSearchTakeOverWindow{
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _userMenuViewController.view.frame = CGRectMake(-WIDTH/2, 0, WIDTH, HEIGHT);;
                         
                     }
                     completion:^(BOOL finished){
                     }];
}



#pragma mark -
#pragma mark PeoplePicker Custom Methods

- (void)displayPerson:(ABRecordRef)person{
    CFStringRef a = ABRecordCopyCompositeName(person);
    NSLog(@"%@", a);
    ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFRelease(phoneNumbers);
    NSString* phoneNumber = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
    NSLog(@"%@", phoneNumber);
}


#pragma mark -
#pragma mark PeoplePicker Delegate Methods

- (void)peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissViewControllerAnimated:YES completion:nil];
    /*[UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         peoplePicker.view.frame = CGRectMake( WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                         [peoplePicker.view removeFromSuperview];
                     }];*/
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    /*[UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         peoplePicker.view.frame = CGRectMake( WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                         [peoplePicker.view removeFromSuperview];
                     }];*/
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property  identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}

#pragma mark -
#pragma mark Helper Methods

- (void)allocateBlackMask{
    _blackMaskOnTopOfView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
    [_blackMaskOnTopOfView setOpaque:NO];
    [_blackMaskOnTopOfView setAlpha:0.02];
    [_blackMaskOnTopOfView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_blackMaskOnTopOfView];
}


@end


