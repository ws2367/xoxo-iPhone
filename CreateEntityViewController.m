//
//  CreateEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "ViewMultiPostsViewController.h"
#import "Entity.h"
#import "EntityCell.h"

@interface CreateEntityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *institutionTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (strong, nonatomic) UIView *blackMaskOnTopOfView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;
@property (weak, nonatomic) CreatePostViewController *createPostViewController;
@property (weak, nonatomic) IBOutlet UITableView *entityTableView;

@property (strong, nonatomic) NSArray *searchEntityResult;

@end

#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0

@implementation CreateEntityViewController



- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsViewController = viewController;// Custom initialization
    }
    return self;
}


- (id)initWithCreatePostViewController:(CreatePostViewController *)viewController{
    self = [super init];
    if (self) {
        _createPostViewController = viewController;// Custom initialization
    }
    return self;
}


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

static NSString *CellTableIdentifier = @"CellTableIdentifier";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _searchEntityResult = @[
                   @{@"Name" : @"Dan Lin", @"Institution" : @"Duke University", @"Location" : @"Fremont, CA", @"Pic" : @"pic1" },
                   @{@"Name" : @"Iru Wang", @"Institution" : @"Stanford University", @"Location" : @"Stanford, CA", @"Pic" : @"pic2" },
                   @{@"Name" : @"Shawn Shaw", @"Institution" : @"Columbia University", @"Location" : @"New York", @"Pic" : @"pic3" },
                   @{@"Name" : @"Jocelin Ho", @"Institution" : @"Stanford University", @"Location" : @"Stanford, CA", @"Pic" : @"pic4" },
                   @{@"Name" : @"Chiu-Ho Lin", @"Institution" : @"Santa Clara University", @"Location" : @"Santa Clara, CA", @"Pic" : @"pic4" },
                   @{@"Name" : @"Dan Lin 2", @"Institution" : @"Santa Clara University", @"Location" : @"Santa Clara, CA", @"Pic" : @"pic1" },
                   @{@"Name" : @"Dan Lin 3", @"Institution" : @"Santa Clara University", @"Location" : @"Santa Clara, CA", @"Pic" : @"pic4" }];
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    
    _entityTableView.rowHeight = 60;
    UINib *nib = [UINib nibWithNibName:@"EntityCell"
                                bundle:nil];
    [_entityTableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Button Pressed Functions

- (IBAction)notHereButtonPressed:(id)sender {
    [self allocateBlackMask];
    _selectedEntity = [[Entity alloc] init];
    _selectedEntity.name = _nameTextField.text;
    _selectedEntity.institution = _institutionTextField.text;
    _selectedEntity.location = _locationTextField.text;
    [_viewMultiPostsViewController finishCreatingEntityStartCreatingPost];
}


- (IBAction)cancelButtonPressed:(id)sender {
    //[(ViewMultiPostsViewController *)[self presentingViewController] cancelButton];
    //[(ViewMultiPostsViewController *)self.presentingViewController cancelButton];
    [_viewMultiPostsViewController cancelCreatingEntity];
}




#pragma mark -
#pragma mark TextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_searchEntityResult count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntityCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = _searchEntityResult[indexPath.row];
    cell.name = rowData[@"Name"];
    cell.institution =rowData[@"Institution"];
    cell.location =rowData[@"Location"];
    cell.pic = rowData[@"Pic"];
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectrow");
    [self allocateBlackMask];
    
     NSDictionary *rowData = _searchEntityResult[indexPath.row];
    
    _selectedEntity = [[Entity alloc] init];
    _selectedEntity.name = rowData[@"Name"];
    _selectedEntity.institution = rowData[@"Institution"];
    _selectedEntity.location = rowData[@"Location"];
    if (_viewMultiPostsViewController)
        [_viewMultiPostsViewController finishCreatingEntityStartCreatingPost];
    else if(_createPostViewController)
        [_createPostViewController finishAddingEntity];
    
    //    - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
    //        [tableView deselectRowAtIndexPath:indexPath animated:NO];
    //        NSInteger catIndex = [taskCategories indexOfObject:self.currentCategory];
    //        if (catIndex == indexPath.row) {
    //            return;
    //        }
    //        NSIndexPath *oldIndexPath = [NSIndexPath indexPathForRow:catIndex inSection:0];
    //
    //        UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    //        if (newCell.accessoryType == UITableViewCellAccessoryNone) {
    //            newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    //            self.currentCategory = [taskCategories objectAtIndex:indexPath.row];
    //        }
    //
    //        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:oldIndexPath];
    //        if (oldCell.accessoryType == UITableViewCellAccessoryCheckmark) {
    //            oldCell.accessoryType = UITableViewCellAccessoryNone;
    //        }
    //    }
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

#pragma mark -
#pragma mark Controlled by BIDController Methods
- (void)dismissBlackMask{
    [_blackMaskOnTopOfView removeFromSuperview];
}

@end
