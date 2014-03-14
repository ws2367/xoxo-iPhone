//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewEntityViewController.h"
#import "BigPostTableViewCell.h"
#import "ViewMultiPostsViewController.h"
#import <MapKit/MapKit.h>
#import "MapPinAnnotation.h"

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

// store post array temorarily
@property (copy, nonatomic) NSArray *posts;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

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
    
    /*
    [_circleViewForImage setImage:[UIImage imageNamed:@"pic2"]];

    _tableView.rowHeight = 254;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    [_myMap setDelegate:self];
    */
    
    /*
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = 53.58448;
    ctrpoint.longitude =-8.93772;
    MapPinAnnotation *mapPinAnnotation = [[MapPinAnnotation alloc] initWithCoordinates:ctrpoint
                                                                             placeName:nil
                                                                           description:nil];
    
    [_myMap addAnnotation:mapPinAnnotation];
    [mapPinAnnotation release];
    _myMap.showsUserLocation = FALSE;
    [self updateMap];
    */
    
    /*For creating a mask
    CALayer *imageLayer = _headImageView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:1];
    [imageLayer setMasksToBounds:YES];
     */
    
    // set up entity
    // TODO: make sure that Core Data makes every name attribute is filled
    if (_entity) {
        _name = [[NSString alloc] initWithString:_entity.name];
        _nameLabel.text = _name;
        NSLog(@"name: %@", _name);
        if (_entity.institution) {
            _institution = [[NSString alloc] initWithString:_entity.institution.name];
            _institutionLabel.text = _institution;
            NSLog(@"inst: %@", _institution);
        
            if (_entity.institution.location) {
                _location = [[NSString alloc] initWithString:_entity.institution.location.name];
                _locationLabel.text = _location;
                NSLog(@"location: %@", _location);
            }
        }
    }
    // store posts in an NSArray
    _posts = [_entity.posts sortedArrayUsingDescriptors:
              @[[NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:YES]]];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Update Methods
- (void)updateMap{
    
    [_myMap removeAnnotations:_myMap.annotations];
    //series of coordinates
    CLLocationCoordinate2D myCoordinate1 = {45, 121.5};
    CLLocationCoordinate2D myCoordinate2 = {46, 120};
    CLLocationCoordinate2D myCoordinate3 = {30, 122};
    
    //Create your annotation
    MKPointAnnotation *point1 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *point2 = [[MKPointAnnotation alloc] init];
    MKPointAnnotation *point3 = [[MKPointAnnotation alloc] init];
    // Set your annotation to point at your coordinate
    point1.coordinate = myCoordinate1;
    point2.coordinate = myCoordinate2;
    point3.coordinate = myCoordinate3;
    
    NSArray *myPoints = @[point1,point2,point3];
    //If you want to clear other pins/annotations this is how to do it
    //for (id annotation in _myMap.annotations) {
    //    [_myMap removeAnnotation:annotation];
    //}
    //Drop pin on map
    
    [_myMap addAnnotations:myPoints];
    [_myMap showAnnotations:myPoints animated:YES];
    

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
    
    [self updateMap];
    
    //adjust View Region
    /*
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(myCoordinate, 1900*METERS_PER_MILE, 1900*METERS_PER_MILE);
    MKCoordinateRegion adjustedRegion = [_myMap regionThatFits:viewRegion];
    
    _myMap.autoresizingMask =
    (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
    
    [_myMap setRegion:adjustedRegion animated:YES];
     */

}
#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    Post *post = _posts[indexPath.row];
    cell.content = post.content;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [post.entities enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [array addObject:[NSDictionary dictionaryWithObject:[(Entity *)obj name] forKey:@"name"]];
    }];
    
    cell.entities = array;
    //TODO: should present all images, not just the first one
    if ([post.photos count] > 0) {
        Photo *photo = [[post.photos allObjects] firstObject];
        cell.image = [[UIImage alloc] initWithData:photo.image];
    }
    
    return cell;
}

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

@end
