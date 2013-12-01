//
//  ViewPostViewController.m
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewPostViewController.h"
#import "BIDViewController.h"
#import "CommentTableViewCell.h"

@interface ViewPostViewController ()

@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (strong, nonatomic) NSArray *comments;
@property (weak, nonatomic)IBOutlet UIImageView *postImage;
@property (weak, nonatomic) BIDViewController *bidViewController;

@end

#define ROW_HEIGHT 46

@implementation ViewPostViewController



static NSString *CellTableIdentifier = @"CellTableIdentifier";



- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
    }
    return self;
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *firstData =
    @{@"comment" : @"This guy seems like having a good time in Taiwan. Does not he know he has a girl friend?" };
    NSDictionary *secondData =
    @{@"comment" : @"One of the partners of Orrzs is cute!!!"};
    NSDictionary *thirdData =
    @{@"comment" : @"Who is that girl? Heartbreak..." };
    NSDictionary *fourthData =
    @{@"comment" : @"Seriously, another girl?" };
    NSDictionary *fifthData =
    @{@"comment" : @"人生第一次當個瘋狂蘋果迷", };
    
    //Shawn test
    //self.posts = [[NSMutableArray alloc] init];
    
    //Iru test
    _comments = [[NSMutableArray alloc] initWithObjects:firstData,secondData,thirdData,fourthData,fifthData, nil];
    // Do any additional setup after loading the view from its nib.
    
    _myTableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"CommentTableViewCell"
                                bundle:nil];
    [_myTableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
}
- (IBAction)backButtonPressed:(id)sender {
    [_bidViewController cancelViewingPost];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPic:(NSString *)c
{
    if (![c isEqualToString:_pic]) {
        _pic = [c copy];
        _postImage.image = [UIImage imageNamed:_pic];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_comments count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = _comments[indexPath.row];
    cell.commentStr = rowData[@"comment"];
    return cell;
}




@end
