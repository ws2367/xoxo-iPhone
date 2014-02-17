//
//  ViewMultiPostsVC.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewMultiPostsVC.h"
#import "BigPostTableViewCell.h"
#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "Entity.h"
#import "ViewPostViewController.h"
#import "ViewEntityViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ServerConnector.h"
#import "UserMenuViewController.h"

@interface ViewMultiPostsVC ()


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
@property (strong, nonatomic) UITableViewController *TVC;
@property (strong, nonatomic) UIRefreshControl *refreshControlOfTVC;
@property (strong, nonatomic) ServerConnector *serverConnector;

@end

#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0
// TODO: change the hard-coded number here to the height of the xib of BigPostTableViewCell
// TODO: rename TableViewCell to TVC
#define ROW_HEIGHT 218
#define POSTS_INCREMENT_NUM 5

@implementation ViewMultiPostsVC


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
    //[[ServerConnector alloc] initWithURL:@"http://gentle-atoll-8604.herokuapp.com/orderposts.json"
    [[ServerConnector alloc] initWithURL:@"http://localhost:3000/orderposts.json"
                                    verb:@"post"
                             requestType:@"application/json"
                            responseType:@"application/json"
                         timeoutInterval:60
                          viewController:self];
    
    _tableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    
    //[tableView registerClass:[BIDNameAndColorCell class]
    //forCellReuseIdentifier:CellTableIdentifier];
	// Do any additional setup after loading the view, typically from a nib.
    
    //Adding a tableViewController to have the refreshControl on our tableView
    _TVC = [[UITableViewController alloc] init];
    _TVC.tableView = _tableView;
    _refreshControlOfTVC = [UIRefreshControl new];
    _TVC.refreshControl = _refreshControlOfTVC;
    [_TVC.refreshControl addTarget:self action:@selector(startRefreshingView) forControlEvents:UIControlEventValueChanged];
    //[_TVC.refreshControl beginRefreshing];
    //[self startRefreshingView];
    
    
    //swipe cells
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [_tableView addGestureRecognizer:recognizerRight];
    [_tableView addGestureRecognizer:recognizerLeft];
    
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
// This method does not actually overload any method of the parent
-(void)startRefreshingView{
    //must be here because it can not be in viewDidLoad
    [_refreshControlOfTVC beginRefreshing];
    
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
    
    [_serverConnector sendJSONGetJSONArray:data];
}

-(void)endRefreshingViewWithJSONArr:(NSArray *)JSONArr{
    [self.posts removeAllObjects];
    
    NSLog(@"%@", JSONArr);
    
    for(NSDictionary *item in JSONArr) {
        [self.posts addObject:item];
    }
    
    //NSLog(@"Count posts: %d", [self.posts count]);
    
    [_tableView reloadData];
    [_refreshControlOfTVC endRefreshing];
    
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
    _createPostController = [[CreatePostViewController alloc] initWithViewMultiPostsVC:self];
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
        _createEntityController =[[CreateEntityViewController alloc] initWithViewMultiPostsVC:self];
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

    
    
    _userMenuViewController = [[UserMenuViewController alloc] initWithViewMultiPostsVC:self];
    
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



-(void)entityButtonPressed:(UIButton *)sender{
    [self allocateBlackMask];
    _viewEntityViewController = [[ViewEntityViewController alloc] initWithViewMultiPostsVC:self];
    
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

// This is where cells got data and set up
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = self.posts[indexPath.row];
    cell.content = rowData[@"content"];
    
    
    //uncomment one of these (hasnt made compatible to both)
    
    
    //to test dummy cells
    //NSString *entitiesOfPost = rowData[@"entities"];
    //cell.entity = entitiesOfPost;
    
    //to connect to server
    NSArray *entitiesOfPost = rowData[@"entities"];
    cell.entities = entitiesOfPost;
    
    
    cell.pic = rowData[@"pic"];
    // We want the cell to know which row it is, so we store that in button.tag
    // However, here shareButton is depreciated
    cell.shareButton.tag = indexPath.row;
    // Here is where we register any target of buttons in cells if the target is not the cell itself
    [cell.shareButton addTarget:self action:@selector(shareButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    cell.entityButton.tag = indexPath.row;
    [cell.entityButton addTarget:self action:@selector(entityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = cell.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                       (id)[[UIColor colorWithWhite:0 alpha:0.3] CGColor], nil];
    [cell.layer addSublayer:gradient];
    NSLog(@"adding gradient");
    */
    
    
    return cell;
}
#pragma mark -
#pragma mark TableView Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self allocateBlackMask];
    
    _viewPostViewController = [[ViewPostViewController alloc] initWithViewMultiPostsVC:self];
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
            
            [_tableView reloadData];
        }
        
    }
}

#pragma mark -
#pragma mark Swipe Table Cell Methods
- (void)handleSwipe:(UISwipeGestureRecognizer *)aSwipeGestureRecognizer; {
    CGPoint location = [aSwipeGestureRecognizer locationInView:_tableView];
    NSIndexPath * indexPath = [_tableView indexPathForRowAtPoint:location];
    
    if(indexPath){
        BigPostTableViewCell * cell = (BigPostTableViewCell *)[_tableView cellForRowAtIndexPath:indexPath];
        if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            [cell symptomCellSwipeRight];
            NSLog(@"swipeRight at %d",indexPath.row);
        }
        else if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
            [self sharePost];
            NSLog(@"swipeLeft at %d",indexPath.row);
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



