//
//  BIDViewController.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BIDViewController.h"
#import "BigPostTableViewCell.h"
#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "Entity.h"
#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ServerConnector.h"

@interface BIDViewController ()

@property (weak, nonatomic) IBOutlet UIView *topUIView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolBar;
@property (strong, nonatomic) CreateEntityViewController *createEntityController;
@property (strong, nonatomic) CreatePostViewController *createPostController;
@property (strong, nonatomic) ViewPostViewController *viewPostViewController;
@property (strong, nonatomic) ViewEntityViewController *viewEntityViewController;
//@property (strong, nonatomic) UIToolbar *toCreateEntityToolbar;
//@property (strong, nonatomic) UIButton *notHereButton;

//@property (strong, nonatomic) UIToolbar *toCreatePostToolbar;

//Try adding a table view controller and UIRefreshControl
@property (strong, nonatomic) UITableViewController *tableViewController;
@property (strong, nonatomic) UIRefreshControl *myRefreshControl;
@property (strong, nonatomic) ServerConnector *serverConnector;

@end

#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0
#define ROW_HEIGHT 220
#define POSTS_INCREMENT_NUM 5

@implementation BIDViewController


static NSString *CellTableIdentifier = @"CellTableIdentifier";



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.posts = [[NSMutableArray alloc] init];

    _serverConnector =
    [[ServerConnector alloc] initWithURL:@"http://localhost:3000/orderposts.json"
                                    verb:@"post"
                             requestType:@"application/json"
                            responseType:@"application/json"
                         timeoutInterval:60
                          viewController:self];
    
    [_topUIView setAlpha:0.8];
    _myTableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [_myTableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    
    //[tableView registerClass:[BIDNameAndColorCell class]
    //forCellReuseIdentifier:CellTableIdentifier];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Adding a tableViewController to have the refreshControl on our tableView
    _tableViewController = [[UITableViewController alloc] init];
    _tableViewController.tableView = _myTableView;
    _myRefreshControl = [UIRefreshControl new];
    _tableViewController.refreshControl = _myRefreshControl;
    [_tableViewController.refreshControl addTarget:self action:@selector(startRefreshingView) forControlEvents:UIControlEventValueChanged];
    //[_tableViewController.refreshControl beginRefreshing];
    [self startRefreshingView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark -
#pragma mark Parent Overloaded Methods

-(void)startRefreshingView{
    //must be here because it can not be in viewDidLoad
    [_myRefreshControl beginRefreshing];
    //NSLog(@"start refreshing");
    
    //send out request
    NSString *numPosts = [NSString stringWithFormat:@"%d",[self.posts count] + POSTS_INCREMENT_NUM];
    NSDictionary *data = @{@"num" : numPosts, @"sortby" : @"recent"};
    //NSLog(@"To download %@ posts.", numPosts);
    
    [_serverConnector sendJSONGetJSONArray:data];
}

-(void)endRefreshingViewWithJSONArr:(NSArray *)JSONArr{
    //NSLog(@"end refreshing");
    
    [self.posts removeAllObjects];
    
    for(NSDictionary *item in JSONArr) {
        [self.posts addObject:item];
    }
    
    //NSLog(@"Count posts: %d", [self.posts count]);
    
    [_myTableView reloadData];
    [_myRefreshControl endRefreshing];
    
}

/*
- (void)RefreshViewWithJSONArr:(NSArray *)JSONArr
{
    self.posts = JSONArr;
    
    NSLog(@"Gonna refresh view!");
    
    if (!JSONArr) {
        NSLog(@"Error parsing JSON!");
    } else {
        for(NSDictionary *item in JSONArr) {
            NSLog(@"Item: %@", item);
        }
    }
    
    
 
     if (!jsonArr) {
     NSLog(@"Error parsing JSON!");
     } else {
     for(NSDictionary *item in jsonArr) {
     NSLog(@"Item: %@", item);
     }
     }
     
     
     NSArray *jsonArr2 = [poster sendJSONGetJSONArray:@{@"num" : @"3", @"sortby" : @"recent"}];
     for(NSDictionary *item in jsonArr2) {
     NSLog(@"Item2: %@", item);
     }
     
     NSURL *url2 = [NSURL URLWithString:@"http://localhost:3000/hates"];
     [poster setUrl:url2];
     NSArray *jsonArr3 = [poster sendJSONGetJSONArray:@{@"user_id" : @"5", @"hate":@{@"hatee_id":@"3", @"hatee_type":@"Post"}}];
     
     for(NSDictionary *item in jsonArr3) {
     NSLog(@"Item3: %@", item);
     }

}
*/

#pragma mark -
#pragma mark Switch View Methods


- (void)cancelCreatingEntity{
    
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
                     }];
    
    [_createEntityController.view endEditing:YES];
    
}

- (void)cancelCreatingPost{
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);

                     }
                     completion:^(BOOL finished){
                     }];
    
    [_createPostController.view endEditing:YES];
 
    
}

- (void)cancelViewingPost{
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
        
    
}

- (void)cancelViewingEntity{
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewEntityViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    
}


- (void)finishCreatingPostBackToHomePage{
    
    
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
    _createPostController = [[CreatePostViewController alloc] initWithBIDViewController:self];
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


- (IBAction)startCreatingEntity:(id)sender {
    
    
    

        _createEntityController =[[CreateEntityViewController alloc] initWithBIDViewController:self];
    

    
    //UIBarButtonItem *space = [[UIBarButtonItem alloc] ini

    //_toCreateEntityToolbar = [self createPostToolbarForEntity:true];
    //_notHereButton = [self createNotHereButton];
     _createEntityController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);

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
    [self.view addSubview:_createEntityController.view];


}

#pragma mark -
#pragma mark Button Methods

-(void)shareButtonPressed{
    NSLog(@"shareButtonPressed");
    ABPeoplePickerNavigationController *picker =[[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
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

-(void)entityButtonPressed:(UIButton *)sender{
    _viewEntityViewController = [[ViewEntityViewController alloc] initWithBIDViewController:self];
    
    _viewEntityViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    NSDictionary *rowData = self.posts[sender.tag];
    [_viewEntityViewController setEntityName:rowData[@"entity"]];
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



#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [self.posts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = self.posts[indexPath.row];
    cell.content = rowData[@"content"];
    cell.entity = rowData[@"entity"];
    cell.pic = rowData[@"pic"];
    cell.shareButton.tag = indexPath.row;
    [cell.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cell.entityButton.tag = indexPath.row;
    [cell.entityButton addTarget:self action:@selector(entityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    
    return cell;
}
#pragma mark -
#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"here!");
    _viewPostViewController = [[ViewPostViewController alloc] initWithBIDViewController:self];
    NSDictionary *rowData = self.posts[indexPath.row];
    
    _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    _viewPostViewController.pic = rowData[@"Pic"];
    
    
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _viewPostViewController.view.frame = CGRectMake(0, 0, WIDTH, HEIGHT);
                         
                     }
                     completion:^(BOOL finished){
                     }];
    
    //[self.view insertSubview:self.postController.view atIndex:1];
    [self.view addSubview:_viewPostViewController.view];

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
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    [self displayPerson:person];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    return NO;
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property  identifier:(ABMultiValueIdentifier)identifier{
    return NO;
}


@end
