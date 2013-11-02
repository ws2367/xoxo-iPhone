//
//  CreateEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreateEntityViewController.h"
#import "CreatePostViewController.h"
#import "BIDViewController.h"
#import "Entity.h"
#import "EntityCell.h"

@interface CreateEntityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *institutionTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) BIDViewController *bidViewController;
@property (weak, nonatomic) CreatePostViewController *createPostViewController;
@property (weak, nonatomic) IBOutlet UITableView *entityTableView;

@property (strong, nonatomic) NSArray *searchEntityResult;

@end

@implementation CreateEntityViewController



- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
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
    _selectedEntity = [[Entity alloc] init];
    _selectedEntity.name = _nameTextField.text;
    _selectedEntity.institution = _institutionTextField.text;
    _selectedEntity.location = _locationTextField.text;
    [_bidViewController finishCreatingEntityStartCreatingPost];
}


- (IBAction)cancelButtonPressed:(id)sender {
    //[(BIDViewController *)[self presentingViewController] cancelButton];
    //[(BIDViewController *)self.presentingViewController cancelButton];
    [_bidViewController cancelCreatingEntity];
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
     NSDictionary *rowData = _searchEntityResult[indexPath.row];
    
    _selectedEntity = [[Entity alloc] init];
    _selectedEntity.name = rowData[@"Name"];
    _selectedEntity.institution = rowData[@"Institution"];
    _selectedEntity.location = rowData[@"Location"];
    if (_bidViewController)
        [_bidViewController finishCreatingEntityStartCreatingPost];
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




@end
