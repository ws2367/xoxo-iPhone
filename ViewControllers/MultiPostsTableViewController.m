//
//  MultiPostsTableViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewMultiPostsViewController.h"
#import "MultiPostsTableViewController.h"
#import "BigPostTableViewCell.h"

// TODO: change the hard-coded number here to the height of the xib of BigPostTableViewCell
#define ROW_HEIGHT 218
#define POSTS_INCREMENT_NUM 5

@interface MultiPostsTableViewController ()


@end

@implementation MultiPostsTableViewController

static NSString *CellTableIdentifier = @"CellTableIdentifier";


- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


// This will never get called because this table view controller is used for controlling tableview that
// is already loaded in ViewMultiPostsViewController
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)setup
{
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
    
    /*
     _serverConnector =
     //[[ServerConnector alloc] initWithURL:@"http://gentle-atoll-8604.herokuapp.com/orderposts.json"
     [[ServerConnector alloc] initWithURL:@"http://localhost:3000/orderposts.json"
     verb:@"post"
     requestType:@"application/json"
     responseType:@"application/json"
     timeoutInterval:60
     viewController:self];
     */
    
    self.tableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:CellTableIdentifier];
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(startRefreshingView) forControlEvents:UIControlEventValueChanged];

    //[self startRefreshingView];
    
    // set up swipe gesture recognizer
    UISwipeGestureRecognizer * recognizerRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerRight setDirection:UISwipeGestureRecognizerDirectionRight];
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipe:)];
    [recognizerLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.tableView addGestureRecognizer:recognizerRight];
    [self.tableView addGestureRecognizer:recognizerLeft];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


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
// This has to call parent controller to
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [_masterController startViewingPostForPost:nil];
}


#pragma mark -
#pragma mark Swipe Table Cell Methods
- (void)handleSwipe:(UISwipeGestureRecognizer *)aSwipeGestureRecognizer; {
    CGPoint location = [aSwipeGestureRecognizer locationInView:self.tableView];
    NSIndexPath * indexPath = [self.tableView indexPathForRowAtPoint:location];
    
    if(indexPath){
        BigPostTableViewCell * cell = (BigPostTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionRight){
            [cell symptomCellSwipeRight];
            NSLog(@"swipeRight at %d",indexPath.row);
        }
        else if(aSwipeGestureRecognizer.direction == UISwipeGestureRecognizerDirectionLeft){
            [_masterController sharePost];
            NSLog(@"swipeLeft at %d",indexPath.row);
        }
    }
}


#pragma mark -
#pragma mark In-cell Button Methods

-(void)entityButtonPressed:(UIButton *)sender{
    
    [_masterController startViewingEntityForEntity:nil];
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
        if(_posts.count < 20){
            
            NSDictionary *entity6 = @{ @"name": @"Dan Lin, Duke University, Durham"};
            NSDictionary *entity7 = @{ @"name": @"Iru Wang, Stanford University, Palo Alto"};
            NSDictionary *sixthData =
            @{@"content" : @"new sixth cell's content!!!!!!", @"entities" : @[entity6], @"pic" : @"pic3" };
            NSDictionary *seventhData =
            @{@"content" : @"omgomgomgomgomg", @"entities" : @[entity7], @"pic" : @"pic1" };
            
            [_posts addObject:sixthData];
            [_posts addObject:seventhData];
            [self.tableView reloadData];
        }
        
    }
}



#pragma mark -
#pragma mark Parent Overloaded Methods
// This method does not actually overload any method of the parent
-(void)startRefreshingView{
    //must be here because it can not be in viewDidLoad
    [self.refreshControl beginRefreshing];
    
    //send out request
    NSString *numPosts = [NSString stringWithFormat:@"%d",[self.posts count] + POSTS_INCREMENT_NUM];

    
    //TODO: Fetch data from Model according to different status of segmentedControl
    /*
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
     */
}

-(void)endRefreshingViewWithJSONArr:(NSArray *)JSONArr{
    [self.posts removeAllObjects];
    
    NSLog(@"%@", JSONArr);
    
    for(NSDictionary *item in JSONArr) {
        [self.posts addObject:item];
    }
    
    //NSLog(@"Count posts: %d", [self.posts count]);
    
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
    
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



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
