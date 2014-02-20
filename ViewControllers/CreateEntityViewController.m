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
#import "EntityTableViewCell.h"
#import "Institution.h"
#import "Location.h"

@interface CreateEntityViewController ()

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *institutionTextField;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (strong, nonatomic) UIView *blackMaskOnTopOfView;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;
@property (weak, nonatomic) CreatePostViewController *createPostViewController;

// table view
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITableViewController *tableViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
        
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    
    // TODO: change this hard-coded number to the actual height of xib
    _tableView.rowHeight = 60;
    UINib *nib = [UINib nibWithNibName:@"EntityTableViewCell"
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    // set up table view controller
    _tableViewController = [[UITableViewController alloc] init];
    _tableViewController.tableView = _tableView;
    
    // set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[nameSort];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    _fetchedResultsController =
        [[NSFetchedResultsController alloc]
            initWithFetchRequest:request
            managedObjectContext:appDelegate.managedObjectContext
            sectionNameKeyPath:nil
                    cacheName:nil];
    
    _fetchedResultsController.delegate = self;
    
    // Let's perform one fetch here
    NSError *fetchingErr = nil;
    if ([self.fetchedResultsController performFetch:&fetchingErr]){
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }

    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Fetched Results Controller Delegate Methods

- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView beginUpdates];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller{
    [self.tableView endUpdates];
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath{
    
    if (type == NSFetchedResultsChangeDelete) {
        [self.tableView
         deleteRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        [self.tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark -
#pragma mark Button Pressed Functions

- (IBAction)notHereButtonPressed:(id)sender {
    [self allocateBlackMask];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    _selectedEntity =
        [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                      inManagedObjectContext:appDelegate.managedObjectContext];

    _selectedEntity.name = _nameTextField.text;
    
    // TODO: check if the institution and location is in the database, not just create them blindly
    // TODO: Consider to add setters of properties of Institution through catergories and class extension
    _selectedEntity.institution =
        [NSEntityDescription insertNewObjectForEntityForName:@"Institution"
                                      inManagedObjectContext:appDelegate.managedObjectContext];

    _selectedEntity.institution.name = _institutionTextField.text;
    _selectedEntity.institution.location =
        [NSEntityDescription insertNewObjectForEntityForName:@"Location"
                                      inManagedObjectContext:appDelegate.managedObjectContext];

    _selectedEntity.institution.location.name = _locationTextField.text;
    
    // TODO: we might want to save new entities before creating posts, if so, do context save here
    
    [_viewMultiPostsViewController finishCreatingEntityStartCreatingPost];
}


- (IBAction)cancelButtonPressed:(id)sender {
    //[(ViewMultiPostsViewController *)[self presentingViewController] cancelButton];
    //[(ViewMultiPostsViewController *)self.presentingViewController cancelButton];
    [_viewMultiPostsViewController cancelCreatingEntity];
}


- (BOOL) MOOSE_compareUIColorBetween:(UIColor *)colorA and:(UIColor *)colorB
{
    CGFloat redA, redB, greenA, greenB, blueA, blueB, alphaA, alphaB;
    [colorA getRed:&redA green:&greenA blue:&blueA alpha:&alphaA];
    [colorB getRed:&redB green:&greenB blue:&blueB alpha:&alphaB];
    
    if (redA == redB && greenA == greenB && blueA == blueB && alphaA == alphaB)
        return FALSE;
    else
        return TRUE;
}



#pragma mark -
#pragma mark TextField Delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField

{
    if ([self MOOSE_compareUIColorBetween:[textField textColor] and:[UIColor lightGrayColor]]) {
        [textField setText:@""];
        [textField setTextColor:[UIColor blackColor]];
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField

{
    if ([[textField text] isEqualToString:@""]) {
        if (textField == _nameTextField) {
            [textField setText:@"Name"];
        }
        else if (textField == _institutionTextField) {
            [textField setText:@"School or Institution"];
        }
        else if (textField == _locationTextField) {
            [textField setText:@"State"];
        }
        
        [textField setTextColor:[UIColor lightGrayColor]];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    // Maybe it is ok to declare NSFetchedResultsSectionInfo instead of an id?
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    NSLog(@"numbers of entities %d", sectionInfo.numberOfObjects);
    return sectionInfo.numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    // TODO: check if the model is empty then this will raise exception
    // TODO: apply predicate to fetch only matching results
    Entity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.name = entity.name;
    cell.location = entity.institution.location.name;
    cell.institution = entity.institution.name;
    
    cell.pic = @"pic1"; // dummy for now
    
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selectrow");
    [self allocateBlackMask];
    
    _selectedEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    // decide who calls to create entity, that is, are we adding more entities or just the first one?
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
