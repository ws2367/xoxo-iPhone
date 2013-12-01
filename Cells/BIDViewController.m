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
#import "UserMenuViewController.h"

@interface BIDViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (strong, nonatomic) UIView *blackMaskOnTopOfView;
@property (weak, nonatomic) IBOutlet UIView *topUIView;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolBar;
@property (strong, nonatomic) CreateEntityViewController *createEntityController;
@property (strong, nonatomic) CreatePostViewController *createPostController;
@property (strong, nonatomic) ViewPostViewController *viewPostViewController;
@property (strong, nonatomic) ViewEntityViewController *viewEntityViewController;
@property (strong, nonatomic) UserMenuViewController *userMenuViewController;
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
#define ROW_HEIGHT 254
#define POSTS_INCREMENT_NUM 5

@implementation BIDViewController


static NSString *CellTableIdentifier = @"CellTableIdentifier";



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    NSDictionary *firstData =
    @{@"content" : @"This guy seems like having a good time in Taiwan. Does not he know he has a girl friend?", @"entities" : @"Dan Lin, Duke University, Durham", @"pic" : @"pic1" };
    NSDictionary *secondData =
    @{@"content" : @"One of the partners of Orrzs is cute!!!", @"entity" : @"Iru Wang,Stanford University, Palo Alto", @"pic" : @"pic2" };
    NSDictionary *thirdData =
    @{@"content" : @"Who is that girl? Heartbreak...", @"entity" : @"Wen Hsiang Shaw, Columbia University, New York", @"pic" : @"pic3" };
    NSDictionary *fourthData =
    @{@"content" : @"Seriously, another girl?", @"entity" : @"Jeanne Jean, Mission San Jose High School, Fremont", @"pic" : @"pic4" };
    NSDictionary *fifthData =
                   @{@"content" : @"人生第一次當個瘋狂蘋果迷", @"entity" : @"Jocelin Ho,Stanford University, Palo Alto", @"pic" : @"pic5" };
     */
    
    //Shawn test
    self.posts = [[NSMutableArray alloc] init];
    
    //Iru test
    //self.posts = [[NSMutableArray alloc] initWithObjects:firstData,secondData,thirdData,fourthData,fifthData, nil];


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
    //[self startRefreshingView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Segmented Control Methods

- (IBAction)segmentChanged:(id)sender {
    NSInteger selectedIdx = [sender selectedSegmentIndex];
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
    [_serverConnector sendJSONGetJSONArray:data];
}


#pragma mark -
#pragma mark Parent Overloaded Methods

-(void)startRefreshingView{
    //must be here because it can not be in viewDidLoad
    [_myRefreshControl beginRefreshing];
    //NSLog(@"start refreshing");
    
    //send out request
    NSString *numPosts = [NSString stringWithFormat:@"%d",[self.posts count] + POSTS_INCREMENT_NUM];
    
    NSDictionary *data;
    if(_segmentedControl.selectedSegmentIndex == 0){
        data = @{@"num" : numPosts, @"sortby" : @"popularity"};
    }
    else if(_segmentedControl.selectedSegmentIndex == 1){
        data = @{@"num" : numPosts, @"sortby" : @"recent"};
    }
    else{
        data = @{@"num" : numPosts, @"sortby" : @"popularity"};
    }
    //NSLog(@"To download %@ posts.", numPosts);
    
    [_serverConnector sendJSONGetJSONArray:data];
}

-(void)endRefreshingViewWithJSONArr:(NSArray *)JSONArr{
    //NSLog(@"end refreshing");
    
    [self.posts removeAllObjects];
    
    NSLog(@"%@", JSONArr);
    
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
    
    [_createEntityController.view endEditing:YES];
    
}

- (void)cancelCreatingPost{
    
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
    
    [self allocateBlackMask];
    
    if(_createEntityController == nil){
        _createEntityController =[[CreateEntityViewController alloc] initWithBIDViewController:self];
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
#pragma mark Button Methods
- (IBAction)userMenuButtonPressed:(id)sender {
    
    [self allocateBlackMask];
    UITapGestureRecognizer *tapBIDView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelUserMenu)];
    [_blackMaskOnTopOfView addGestureRecognizer:tapBIDView];

    
    
    _userMenuViewController = [[UserMenuViewController alloc] initWithBIDViewController:self];
    
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
    [self allocateBlackMask];
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
    NSArray *entitiesOfPost = rowData[@"entities"];
    cell.entities = entitiesOfPost;
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
    
    [self allocateBlackMask];
    
    _viewPostViewController = [[ViewPostViewController alloc] initWithBIDViewController:self];
    NSDictionary *rowData = self.posts[indexPath.row];
    
    _viewPostViewController.view.frame = CGRectMake(WIDTH, 0, WIDTH, HEIGHT);
    _viewPostViewController.pic = rowData[@"pic"];
    
    
    
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
#pragma mark UIScrollView Delegate Methods

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat height = scrollView.frame.size.height;
    
    CGFloat contentYoffset = scrollView.contentOffset.y;
    
    CGFloat distanceFromBottom = scrollView.contentSize.height - contentYoffset;
    
    if(distanceFromBottom < height)
    {
        NSLog(@"end of the table %d", [_posts count]);
        if(_posts.count < 20 &&  _segmentedControl.selectedSegmentIndex == 0){
            NSDictionary *sixthData =
            @{@"content" : @"new sixth cell's content!!!!!!", @"entity" : @"Dan Lin, Duke University, Durham", @"pic" : @"pic3" };
            NSDictionary *seventhData =
            @{@"content" : @"omgomgomgomgomg", @"entity" : @"Dan Lin, Duke University, Durham", @"pic" : @"pic1" };
            
            [_posts addObject:sixthData];
            [_posts addObject:seventhData];
            
            [_myTableView reloadData];
        }
        
    }
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



