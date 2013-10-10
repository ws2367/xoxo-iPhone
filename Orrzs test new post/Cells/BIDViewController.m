//
//  BIDViewController.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BIDViewController.h"
#import "BIDNameAndColorCell.h"
#import "NewPostViewController.h"
#import "CreatePostViewController.h"
#import "Entity.h"

@interface BIDViewController ()
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *postButton;
@property (weak, nonatomic) IBOutlet UIToolbar *myToolBar;

@property (strong, nonatomic) UIToolbar *postToolbar;
@property (strong, nonatomic) UIButton *notHereButton;

@property (strong, nonatomic) UIToolbar *createPostToolbar;

@end

@implementation BIDViewController
- (void)backButton{

    
    [UIView animateWithDuration:0.5
                          delay:0.1
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.postController.view.frame = CGRectMake(0, 490, 320, 460);
                         _postToolbar.frame = CGRectMake(0, 490, 320, 44);
                         _notHereButton.frame = CGRectMake(100, 890, 100, 44);
                        //[self.myTableView setAlpha:100];
                     }
                     completion:^(BOOL finished){
                     }];
    
    [_postController.view endEditing:YES];
    
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
    
    Entity *this = [_entities objectAtIndex:0];
    
    NSLog(@"First entity name %@", [this location]);
}

static NSString *CellTableIdentifier = @"CellTableIdentifier";

- (IBAction)leftButtonPressed:(id)sender {
    
    //NSLog(@"%d", [[self.view subviews] count]);
    self.postController =[[NewPostViewController alloc] init];
    
    _postToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"back" style:UIBarButtonItemStyleBordered target:self action:@selector(backButton)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    [spaceItem setWidth:197];
    
    //UIBarButtonItem *nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"next" style:UIBarButtonItemStyleBordered target:self action:@selector(nextButton)];
    
        _postToolbar.items = [NSArray arrayWithObjects:backButtonItem, spaceItem, nil];
    
        [self.view addSubview:_postToolbar];

    
    [self.view insertSubview:self.postController.view atIndex:1];

    
    //[UIView commitAnimations];
}


- (IBAction)newPostButtonPressed:(UIBarButtonItem *)sender {
    
    //NSLog(@"%d", [[self.view subviews] count]);
        self.postController =[[NewPostViewController alloc] init];
    

    


    
    
    //UIBarButtonItem *space = [[UIBarButtonItem alloc] ini

    _postToolbar = [self createPostToolbar];
    _notHereButton = [self createNotHereButton];
     self.postController.view.frame = CGRectMake(0, 490, 320, 460);

    /*
    [UIView setAnimationTransition:
    UIViewAnimationTransitionCurlDown forView:self.view cache:YES];
    */
     
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationCurveEaseIn
                     animations:^{
                         self.postController.view.frame = CGRectMake(0, 0, 320, 460);
                         _postToolbar.frame = CGRectMake(0, 0, 320, 44);
                         _notHereButton.frame = CGRectMake(100, 400, 100, 44);
                         //[self.myTableView setAlpha:0];
                         //self.view.backgroundColor = [UIColor whiteColor];
                         }
                     completion:^(BOOL finished){
                     }];

    [self.view insertSubview:self.postController.view atIndex:1];
    [self.view addSubview:_postToolbar];
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


- (UIToolbar *)createPostToolbar{
    UIToolbar *createdToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 490, 320, 44)];
    UIBarButtonItem *backButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(backButton)];
    
    UIBarButtonItem *spaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:self action:nil];
    [spaceItem setWidth:197];
    
    createdToolBar.items = [NSArray arrayWithObjects:backButtonItem, spaceItem,  nil];
    
    return createdToolBar;
}

- (UIButton *)createNotHereButton{
    UIButton *createdButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [createdButton setTitle:@"Not Here!" forState:UIControlStateNormal];
    [createdButton addTarget:self action:@selector(notHereButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    createdButton.frame = CGRectMake(100, 890, 100, 44);
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
