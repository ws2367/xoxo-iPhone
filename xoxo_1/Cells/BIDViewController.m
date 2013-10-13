//
//  BIDViewController.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BIDViewController.h"
#import "BIDNameAndColorCell.h"
#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "Entity.h"

@interface BIDViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolBar;

@property (strong, nonatomic) UIToolbar *toCreateEntityToolbar;
@property (strong, nonatomic) UIButton *notHereButton;

@property (strong, nonatomic) UIToolbar *toCreatePostToolbar;

@end

const NSUInteger HEIGHT = 568;
const NSUInteger WIDTH = 320;

@implementation BIDViewController


- (void)cancelButton{

    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.postController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         _toCreateEntityToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         _notHereButton.frame = CGRectMake(100, HEIGHT + 422, 100, 44);
                        //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [_postController.view endEditing:YES];
    
    //[self.postController.view removeFromSuperview];
    //[self.postToolbar removeFromSuperview];
    //[self.view insertSubview:self.myTableView atIndex:2];
    

    
    
}

- (void)backButton{
    
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         _toCreatePostToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [_createPostController.view endEditing:YES];
    
    //[self.postController.view removeFromSuperview];
    //[self.postToolbar removeFromSuperview];
    //[self.view insertSubview:self.myTableView atIndex:2];
    
    
    
    
}

- (void)postButton{
    
    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         
                         _toCreatePostToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         self.postController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
                         _toCreateEntityToolbar.frame = CGRectMake(0, HEIGHT, WIDTH, 44);
                         _notHereButton.frame = CGRectMake(100, HEIGHT + 422, 100, 44);
                         //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [_createPostController.view endEditing:YES];
    
    //[self.postController.view removeFromSuperview];
    //[self.postToolbar removeFromSuperview];
    //[self.view insertSubview:self.myTableView atIndex:2];
    
    
    
    
}


- (void)notHereButtonPressed{
    Entity *person = [[Entity alloc] init];
    person.name = _postController.name.text;
    person.institution = _postController.institution.text;
    person.location = _postController.location.text;

    if(_entities == nil){
        _entities = [[NSMutableArray alloc] init];
    }
    
    [_entities addObject:person];
    
    _toCreatePostToolbar = [self createPostToolbarForEntity:false];
    _createPostController = [[CreatePostViewController alloc] init];
    self.createPostController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);
    
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.createPostController.view.frame = CGRectMake(0, 22, WIDTH, HEIGHT);
                         _toCreatePostToolbar.frame = CGRectMake(0, 22, WIDTH, 44);
                         //[self.myTableView setAlpha:0];
                         //self.view.backgroundColor = [UIColor whiteColor];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [self.view addSubview:self.createPostController.view];
    [self.view addSubview:_toCreatePostToolbar];

}

static NSString *CellTableIdentifier = @"CellTableIdentifier";

- (IBAction)leftButtonPressed:(id)sender {

    
    //[UIView commitAnimations];
}


- (IBAction)newPostButtonPressed:(UIBarButtonItem *)sender {
    
    
    
    if(_postController == nil){
        self.postController =[[CreateEntityViewController alloc] init];
        NSLog(@"it is nil");
    }
    
    
    //UIBarButtonItem *space = [[UIBarButtonItem alloc] ini

    _toCreateEntityToolbar = [self createPostToolbarForEntity:true];
    _notHereButton = [self createNotHereButton];
     self.postController.view.frame = CGRectMake(0, HEIGHT, WIDTH, HEIGHT);

    /*
    [UIView setAnimationTransition:
    UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    */
     
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.postController.view.frame = CGRectMake(0, 22, WIDTH, HEIGHT);
                         _toCreateEntityToolbar.frame = CGRectMake(0, 22, WIDTH, 44);
                         _notHereButton.frame = CGRectMake(100, 422, 100, 44);
                         //[self.myTableView setAlpha:0];
                         //self.view.backgroundColor = [UIColor whiteColor];
                         }
                     completion:^(BOOL finished){
                     }];

    //[self.view insertSubview:self.postController.view atIndex:1];
    [self.view addSubview:self.postController.view];
    [self.view addSubview:_toCreateEntityToolbar];
    [self.view addSubview:_notHereButton];

    //[UIView commitAnimations];
    

    
    
    
        //[self.myToolBar removeFromSuperview];
        //[self.myTableView removeFromSuperview];
        //[self.ta]
   // }
    //[self.blueViewController.view removeFromSuperview];
    //NSLog(@"%d", [[self.view subviews] count]);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.posts = @[
  @{@"Title" : @"This guy seems like having a good time in Taiwan. Does not he know he has a girl friend?", @"Entity" : @"Dan Lin, Duke University, Durham", @"Pic" : @"pic1" },
  @{@"Title" : @"One of the partners of Orrzs is cute!!!", @"Entity" : @"Iru Wang,Stanford University, Palo Alto", @"Pic" : @"pic2" },
  @{@"Title" : @"Who is that girl? Heartbreak...", @"Entity" : @"Wen Hsiang Shaw, Columbia University, New York", @"Pic" : @"pic3" },
  @{@"Title" : @"Seriously, another girl?", @"Entity" : @"Jeanne Jean, Mission San Jose High School, Fremont", @"Pic" : @"pic4" },
  @{@"Title" : @"人生第一次當個瘋狂蘋果迷", @"Entity" : @"Jocelin Ho,Stanford University, Palo Alto", @"Pic" : @"pic5" }];
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    
    _myTableView.rowHeight = 99;
    UINib *nib = [UINib nibWithNibName:@"BIDNameAndColorCell"
                                bundle:nil];
    [_myTableView registerNib:nib
    forCellReuseIdentifier:CellTableIdentifier];
    
    
    //[tableView registerClass:[BIDNameAndColorCell class]
      //forCellReuseIdentifier:CellTableIdentifier];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (UIToolbar *)createPostToolbarForEntity:(bool)toCreateEntity{
    UIToolbar *createdToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, HEIGHT, WIDTH, 44)];
    UIBarButtonItem *backButton;
    
    if(toCreateEntity){
        backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton)];
    }
    else{
        backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButton)];
    }
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    [spaceItem setWidth:197];
    
    if(toCreateEntity){
        createdToolBar.items = [NSArray arrayWithObjects:backButton, spaceItem,  nil];
    }
    else{
        UIBarButtonItem *toPostButton = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarButtonItemStyleBordered target:self action:@selector(postButton)];
        createdToolBar.items = [NSArray arrayWithObjects:backButton, spaceItem, toPostButton, nil];
    }
    
    
    return createdToolBar;
}

- (UIButton *)createNotHereButton{
    UIButton *createdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createdButton setTitle:@"Not Here!" forState:UIControlStateNormal];
    [createdButton addTarget:self action:@selector(notHereButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    createdButton.frame = CGRectMake(100, HEIGHT + 422, 100, 44);
    return createdButton;
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
    BIDNameAndColorCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = self.posts[indexPath.row];
    cell.title = rowData[@"Title"];
    cell.entity = rowData[@"Entity"];
    cell.pic = rowData[@"Pic"];
    return cell;
}

@end
