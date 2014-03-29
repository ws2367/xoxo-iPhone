//
//  ViewMultiPostsViewController.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <AddressBookUI/AddressBookUI.h>

#import "ViewMultiPostsViewController.h"
#import "BigPostTableViewCell.h"
#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import "UserMenuViewController.h"
#import "MultiPostsTableViewController.h"
#import "Post.h"

#import "ClientManager.h"
#import "KeyChainWrapper.h"

@interface ViewMultiPostsViewController () {
       NSMutableArray       *objects;
}


@property (strong, nonatomic) UIView *blackMaskOnTopOfView;

// children view controllers
@property (strong, nonatomic) CreateEntityViewController *createEntityController;
@property (strong, nonatomic) CreatePostViewController *createPostController;
@property (strong, nonatomic) ViewPostViewController *viewPostViewController;
@property (strong, nonatomic) ViewEntityViewController *viewEntityViewController;
@property (strong, nonatomic) UserMenuViewController *userMenuViewController;

// segmented controller
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) MultiPostsTableViewController *tableViewController;



@end

@implementation ViewMultiPostsViewController
/*
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });
      
        if(listObjectResponse.error != nil)
        {
            NSLog(@"Error: %@", listObjectResponse.error);
        }
        else
        {
            S3ListObjectsResult *listObjectsResults = listObjectResponse.listObjectsResult;
            
            if (objects == nil) {
                objects = [[NSMutableArray alloc] initWithCapacity:[listObjectsResults.objectSummaries count]];
            }
            else {
                [objects removeAllObjects];
            }
            
            // By defrault, listObjects will only return 1000 keys
            // This code will fetch all objects in bucket.
            // NOTE: This could cause the application to run out of memory
            NSString *lastKey = @"";
            for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                [objects addObject:[objectSummary key]];
                lastKey = [objectSummary key];
            }
            
            while (listObjectsResults.isTruncated) {
                listObjectRequest = [[S3ListObjectsRequest alloc] initWithName:@"xoxo_img/pictures"];
                listObjectRequest.marker = lastKey;
                
                listObjectResponse = [[ClientManager s3] listObjects:listObjectRequest];
                if(listObjectResponse.error != nil)
                {
                    NSLog(@"Error: %@", listObjectResponse.error);
                    [objects addObject:@"Unable to load objects!"];
                    
                    break;
                }
                
                listObjectsResults = listObjectResponse.listObjectsResult;
                
                for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
                    [objects addObject:[objectSummary key]];
                    lastKey = [objectSummary key];
                }
            }
            
            NSLog(@"objects %@", objects);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            //[self.tableView reloadData];
        });
    });
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[tableView registerClass:[BIDNameAndColorCell class]
    
    //add a table view 
    _tableViewController = [[MultiPostsTableViewController alloc] init];
    _tableViewController.tableView = _tableView;
    _tableViewController.masterController = self;
    _tableView.delegate = _tableViewController;
    
    
    //S3ListObjectsRequest  *listObjectRequest = [[S3ListObjectsRequest alloc] initWithName:@"xoxo_img"];
    
    // prevent it from throwing exception, let's assign a delegate to it
    //listObjectRequest.delegate = self;
    //S3ListObjectsResponse *listObjectResponse = [[ClientManager s3] listObjects:listObjectRequest];

    //NSArray *array = [[ClientManager s3] listObjectsInBucket:S3BUCKET_NAME];
    
    //for (S3ObjectSummary *x in array) {
    //    NSLog(@"objectSummary: %@",x);
    //}

    //NSMutableArray* objectSummaries = listObjectResponse.listObjectsResult.objectSummaries;

    //for (S3ObjectSummary *x in objectSummaries) {
    //    NSLog(@"objectSummary: %@",x);
    //}

    //NSArray *array = [[ClientManager s3] listObjectsInBucket:@"xoxo_img"];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark -
# pragma mark Amazon Service Request Delegate Methods
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response{
    NSLog(@"complete!");
    NSLog(@"response %@", response);
    NSLog(@"status %d", response.httpStatusCode);
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"didfail Error: %@", error);
}


#pragma mark -
#pragma mark Segmented Control Methods

- (IBAction)changeSegment:(id)sender {
    NSInteger selectedIdx = [sender selectedSegmentIndex];

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
    Entity *entity = _createEntityController.selectedEntity;
    
    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    
    [_entities addObject:entity];
    
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
    _viewPostViewController.post = post;
    _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);

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

    [_viewEntityViewController setEntity:entity]; // this has to be set before making the frame
    _viewEntityViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);

    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewEntityViewController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:_viewEntityViewController.view];

    
}

// this is a test function only
// TODO: remove it after testing is done
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



