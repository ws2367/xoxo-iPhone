//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "BigPostTableViewCell.h"
#import "ViewMultiPostsViewController.h"
#import <MapKit/MapKit.h>
#import "MapPinAnnotation.h"

#import "KeyChainWrapper.h"
#import "Institution.h"
#import "Location.h"
#import "Entity.h"
#import "Photo.h"

#import "CircleViewForImage.h"

@interface ViewEntityViewController ()

// for map, potentially depreciated
@property (weak, nonatomic) IBOutlet UIButton *dropPinButton;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;

@property (weak, nonatomic) IBOutlet CircleViewForImage *circleViewForImage;

// entity attributes
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *institutionLabel;
@property (strong, nonatomic) NSString *institution;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSString *location;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;

@end

@implementation ViewEntityViewController

#define METERS_PER_MILE 1609.344

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsViewController = viewController;// Custom initialization
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
    
    // set up entity
    // TODO: make sure that Core Data makes every name attribute is filled
    [self setNameAndInstitutionAndLocation];
   
    //TODO: prepare post ids and entity ids too
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[sessionToken]
                                                                     forKeys:@[@"auth_token"]];
    
    // return null if not missing
    NSNumber *institutionID = [self fetchMissingInstitutionIDForEntity:_entity];
    if (institutionID) {
        [params setValue:institutionID forKey:@"Institution"];
    }
    
    // Let's ask the server for the posts of this entity!
    [[RKObjectManager sharedManager]
     getObjectsAtPathForRelationship:@"posts"
     ofObject:self.entity
     parameters:params
     success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
         MSDebug(@"Successfully loaded posts for the entity");
         [self setNameAndInstitutionAndLocation];
     }
     failure:[Utility generateFailureAlertWithMessage:@"Can't connect to the server!"]];
    
    // set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY entities.remoteID = %@", _entity.remoteID];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"updateDate" ascending:NO];
    request.sortDescriptors = @[sort];
    [request setPredicate:predicate];
    
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
        MSDebug(@"Number of fetched posts %d", [[self.fetchedResultsController fetchedObjects] count]);
        MSDebug(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch posts for entity");
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


/* Every time when a new post is created, it is first an insert at the bottom of the table view, then a move from the bottom to the top.
 * Then an update because of the context save I think.
 *
 */
- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath{
    
    if (type == NSFetchedResultsChangeDelete) {
        MSDebug(@"we got an delete here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         deleteRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeInsert) {
        MSDebug(@"we got an insert here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         insertRowsAtIndexPaths:@[newIndexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if (type == NSFetchedResultsChangeUpdate) {
        MSDebug(@"we got an update here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView
         reloadRowsAtIndexPaths:@[indexPath]
         withRowAnimation:UITableViewRowAnimationAutomatic];
    } else if (type == NSFetchedResultsChangeMove) {
        MSDebug(@"we got a move here! new %d, old %d",newIndexPath.row, indexPath.row);
        
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = self.fetchedResultsController.sections[section];
    return sectionInfo.numberOfObjects;
}

// This is where cells got data and set up
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    //TODO: check if the model is empty then this will raise exception
    Post *post = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.content = post.content;

    //post.entities is a NSSet but cell.entities is a NSArray
    // actually, here we should do more work than just sending a NSArray of Entity to cell
    // because table view cell should be model-agnostic. So we pass a NSArray of NSDictionary to it
    NSMutableArray *entitiesArray = [[NSMutableArray alloc] init];
    
    [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [entitiesArray addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
    }];
    
    cell.entities = entitiesArray;
    
    //TODO: should present all images, not just the first one
    if ([post.photos count] > 0) {
        Photo *photo = [[post.photos allObjects] firstObject];
        cell.image = [[UIImage alloc] initWithData:photo.image];
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    
    return cell;
}

#pragma mark -
#pragma mark Miscellaneous Methods
- (NSNumber *)fetchMissingInstitutionIDForEntity:(Entity *)entity{
    if (entity.institution.name == nil) {
        return entity.institution.remoteID;
    } else {
        return NULL;
    }
}

- (void) setNameAndInstitutionAndLocation{
    if (_entity) {
        _name = [[NSString alloc] initWithString:_entity.name];
        _nameLabel.text = _name;
        MSDebug(@"Entity name: %@", _name);
        if (_entity.institution) {
            if (_entity.institution.name) {
                _institution = [[NSString alloc] initWithString:_entity.institution.name];
                _institutionLabel.text = _institution;
                MSDebug(@"Entity institution: %@", _institution);
            }
            if (_entity.institution.location) {
                _location = [[NSString alloc] initWithString:_entity.institution.location.name];
                _locationLabel.text = _location;
                MSDebug(@"Entity location: %@", _location);
            }
        }
    }

}


//TODO: remove following methods since they are depreciated

#pragma mark -
#pragma mark Map View Delegate Methods
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation  {
    CLLocationCoordinate2D loc = [newLocation coordinate];
    [_myMap setCenterCoordinate:loc];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    //if ([annotation isKindOfClass:[MKUserLocation class]])
    //    return nil;
    //if (annotation == _myMap.userLocation) {
    //    return nil;
    //}
    MKPinAnnotationView*pinView=nil;
    if(annotation!=_myMap.userLocation)
    {
        static NSString*defaultPin=@"com.invasivecode.pin";
        pinView=(MKPinAnnotationView*)[_myMap dequeueReusableAnnotationViewWithIdentifier:defaultPin];
        if(pinView==nil)
            pinView=[[MKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:defaultPin];
        pinView.pinColor=MKPinAnnotationColorPurple;
        pinView.canShowCallout=YES;
        pinView.animatesDrop=YES;
    }
    else
    {
        [_myMap.userLocation setTitle:@"You are Here!"];
    }
    return pinView;
}

- (void)mapView:(MKMapView *)theMapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    [theMapView setCenterCoordinate:userLocation.location.coordinate animated:YES];
}



#pragma mark -
#pragma mark Button Methods

- (IBAction)meButtonPressed:(id)sender {
    
    _myMap.showsUserLocation = TRUE;
    CLLocationCoordinate2D loc = [_myMap.userLocation coordinate];
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(loc, 1900*METERS_PER_MILE, 1900*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_myMap regionThatFits:viewRegion];
    
    _myMap.autoresizingMask =
    (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [_myMap setRegion:adjustedRegion animated:YES];
    
}

- (IBAction)backButtonPressed:(id)sender {
    [_viewMultiPostsViewController cancelViewingEntity];
}

- (IBAction)dropPinPressed:(id)sender {
    
    
    //adjust View Region
    /*
     MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, 1900*METERS_PER_MILE, 1900*METERS_PER_MILE);
     MKCoordinateRegion adjustedRegion = [_myMap regionThatFits:viewRegion];
     
     _myMap.autoresizingMask =
     (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
     
     [_myMap setRegion:adjustedRegion animated:YES];
     */
    
}

# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"toSelfSegue"]){
        ViewEntityViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        // TODO: get it right! not just send the first entity of that post...
        //we don't know which one is clicked... send the first one for now
        Entity *entity = [[post.entities allObjects] firstObject];
        
        [nextController setEntity:entity];
    }
    else if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
        NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
        Post *post = [_fetchedResultsController objectAtIndexPath:indexPath];
        
        [nextController setPost:post];
    }
}


@end
