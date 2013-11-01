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

@property (weak, nonatomic) IBOutlet UIButton *dropPinButton;
@property (weak, nonatomic) IBOutlet MKMapView *myMap;
@property (weak, nonatomic) IBOutlet UILabel *entityNameLabel;
@property (copy, nonatomic) NSArray *posts;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;
@property (weak, nonatomic) BIDViewController *bidViewController;
@property (copy, nonatomic) NSString *entityName;

@end

@implementation ViewEntityViewController


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
    

    _myTableView.rowHeight = 220;
    UINib *nib = [UINib nibWithNibName:@"BigPostTableViewCell"
                                bundle:nil];
    [_myTableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    CLLocationCoordinate2D  ctrpoint;
    ctrpoint.latitude = 53.58448;
    ctrpoint.longitude =-8.93772;
    MapPinAnnotation *mapPinAnnotation = [[MapPinAnnotation alloc] initWithCoordinates:ctrpoint
                                                                             placeName:nil
                                                                           description:nil];
    [_myMap addAnnotation:mapPinAnnotation];
    //[mapPinAnnotation release];
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
#pragma mark Button Methods


- (IBAction)backButtonPressed:(id)sender {
    [_bidViewController cancelViewingEntity];
}

- (IBAction)dropPinPressed:(id)sender {
    CLLocationCoordinate2D myCoordinate = {2, 2};
    //Create your annotation
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    // Set your annotation to point at your coordinate
    point.coordinate = myCoordinate;
    //If you want to clear other pins/annotations this is how to do it
    for (id annotation in _myMap.annotations) {
        [_myMap removeAnnotation:annotation];
    }
    //Drop pin on map
    [_myMap addAnnotation:point];
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

@end
