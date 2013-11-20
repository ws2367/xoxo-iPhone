//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewEntityViewController.h"
#import "BigPostTableViewCell.h"
#import "BIDViewController.h"
#import <MapKit/MapKit.h>
#import "MapPinAnnotation.h"


@interface ViewEntityViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

@property (weak, nonatomic) IBOutlet UIButton *dropPinButton;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;
@property (weak, nonatomic) IBOutlet UILabel *entityNameLabel;
@property (copy, nonatomic) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) BIDViewController *bidViewController;
@property (copy, nonatomic) NSString *entityName;

@end

@implementation ViewEntityViewController

#define METERS_PER_MILE 1609.344

- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
    }
    return self;
}

static NSString *CellTableIdentifier = @"CellTableIdentifier";

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
    self.posts = @[
                   @{@"Title" : @"This guy seems like having a good time in Taiwan. Does not he know he has a girl friend?", @"Entity" : @"Dan Lin, Duke University, Durham", @"Pic" : @"pic1" },
                   @{@"Title" : @"One of the partners of Orrzs is cute!!!", @"Entity" : @"Iru Wang,Stanford University, Palo Alto", @"Pic" : @"pic2" },
                   @{@"Title" : @"Who is that girl? Heartbreak...", @"Entity" : @"Wen Hsiang Shaw, Columbia University, New York", @"Pic" : @"pic3" },
                   @{@"Title" : @"Seriously, another girl?", @"Entity" : @"Jeanne Jean, Mission San Jose High School, Fremont", @"Pic" : @"pic4" },
                   @{@"Title" : @"人生第一次當個瘋狂蘋果迷", @"Entity" : @"Jocelin Ho,Stanford University, Palo Alto", @"Pic" : @"pic5" }];
    //UITableView *tableView = (id)[self.view viewWithTag:1];
    
    [_headImageView setImage:[UIImage imageNamed:@"pic2"]];

    _myTableView.rowHeight = 254;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [_myTableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    
    [_myMap setDelegate:self];
    
    
    /*
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = 53.58448;
    ctrpoint.longitude =-8.93772;
    MapPinAnnotation *mapPinAnnotation = [[MapPinAnnotation alloc] initWithCoordinates:ctrpoint
                                                                             placeName:nil
                                                                           description:nil];
     */
    //[_myMap addAnnotation:mapPinAnnotation];
    //[mapPinAnnotation release];
    
    
    CALayer *imageLayer = _headImageView.layer;
    [imageLayer setCornerRadius:5];
    [imageLayer setBorderWidth:1];
    [imageLayer setMasksToBounds:YES];
    _myMap.showsUserLocation = FALSE;
    [self updateMap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setEntityName:(NSString *)entityName{
    if (![entityName isEqualToString:_entityName]) {
        _entityName = [entityName copy];
        _entityNameLabel.text = _entityName;
    }
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
    [_bidViewController cancelViewingEntity];
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
    return [self.posts count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BigPostTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    NSDictionary *rowData = self.posts[indexPath.row];
    cell.content = rowData[@"Title"];
    cell.entity = rowData[@"Entity"];
    cell.pic = rowData[@"Pic"];
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
