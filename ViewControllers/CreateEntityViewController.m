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

@property (strong, nonatomic) UIView *blackMaskOnTopOfView;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;
@property (weak, nonatomic) CreatePostViewController *createPostViewController;

// table view
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) UITableViewController *tableViewController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


// TODO: kill dummy pictures
@property (strong, nonatomic) NSMutableArray *pictures;


@end

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
        
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    
    // TODO: change this hard-coded number to the actual height of xib
    
    _tableView.rowHeight = 60;
    UINib *nib = [UINib nibWithNibName:entityCellIdentifier
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:entityCellIdentifier];
    
    // set up table view controller
    _tableViewController = [[UITableViewController alloc] init];
    _tableViewController.tableView = _tableView;
    
    // set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Entity"];
    
    NSSortDescriptor *nameSort = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    request.sortDescriptors = @[nameSort];
    
    _fetchedResultsController =
        [[NSFetchedResultsController alloc]
            initWithFetchRequest:request
            managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
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

    // set up textfield clear button mode
    _nameTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _institutionTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _locationTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    //TODO: kill dummy pictures
    _pictures = [[NSMutableArray alloc] init];
    
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

- (IBAction)addPersonPressed:(id)sender {
    [self allocateBlackMask];
    
    RKManagedObjectStore *managedObjectStore = [RKManagedObjectStore defaultStore];

    // TODO: you might want to check if the entity is really not in the database
    _selectedEntity =
        [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                      inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];

    // set UUID
    [_selectedEntity setUuid:[Utility getUUID]];
    [_selectedEntity setDirty:@YES];

    _selectedEntity.name = _nameTextField.text;
    
    // TODO: Consider to add setters of properties of Institution through catergories and class extension
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Institution"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", _institutionTextField.text];
    
    NSError *error = nil;
    NSArray *matches = [managedObjectStore.mainQueueManagedObjectContext
                        executeFetchRequest:request error:&error];
    
    // there should be only unique institutions
    if (!matches || error || [matches count] > 1) {
        // handle error here
        NSLog(@"Errors in fetching institutions");
    } else if ([matches count]) {
        // found the thing
        _selectedEntity.institution = [matches firstObject];
    } else {
        // found nothing, create it!
        _selectedEntity.institution =
        [NSEntityDescription insertNewObjectForEntityForName:@"Institution"
                                      inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
        
        [_selectedEntity.institution setName:_institutionTextField.text];
        [_selectedEntity.institution setDirty:@YES];
        [_selectedEntity.institution setDeleted:@NO];
        [_selectedEntity.institution setUuid:[Utility getUUID]];
        MSDebug(@"Created an institution with name %@", _selectedEntity.institution.name);
    }
    
    request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", _locationTextField.text];
    matches = [managedObjectStore.mainQueueManagedObjectContext executeFetchRequest:request error:&error];
    
    // there should be only unique locations
    if (!matches || error || [matches count] > 1) {
        // handle error here
        NSLog(@"Errors in fetching locations");
    } else if ([matches count]) {
        // found the thing, then set up relationship
        _selectedEntity.institution.location = [matches firstObject];
        MSDebug(@"Found location %@", _selectedEntity.institution.location.name);
        [_delegate addEntity:_selectedEntity];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        // found nothing, and we don't create Location!!
        NSLog(@"Can't find this location in database, %@", _locationTextField.text);
        [Utility generateAlertWithMessage:@"No such state in America!" error:error];
        
        [self dismissBlackMask];
    }

}

#pragma mark -
#pragma mark TextField Delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField

{
    if ([Utility compareUIColorBetween:[textField textColor] and:[UIColor lightGrayColor]]) {
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
    return sectionInfo.numberOfObjects;
}

// TODO: I am not sure if we want to do a performFetch here
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EntityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:entityCellIdentifier];
    
    // TODO: check if the model is empty then this will raise exception
    // TODO: apply predicate to fetch only matching results
    Entity *entity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.name = entity.name;
    cell.location = entity.institution.location.name;
    cell.institution = entity.institution.name;
    
    // dummy random pictures for now
    // picture array has no insufficient pictures
    if ([_pictures count] < (indexPath.row + 1)){
        [_pictures addObject:[[NSString alloc] initWithFormat:@"pic%d", (arc4random() % 5 + 1)]];
    }
    cell.pic = [_pictures objectAtIndex:indexPath.row];

    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];
    
    return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    [self allocateBlackMask];
    
    _selectedEntity = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    [_delegate addEntity:_selectedEntity];
    [self.navigationController popViewControllerAnimated:YES];
    
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
