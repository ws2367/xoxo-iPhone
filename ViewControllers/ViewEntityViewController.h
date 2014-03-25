//
//  ViewEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Entity.h"

@class ViewMultiPostsViewController;

@interface ViewEntityViewController : UIViewController
                                        <MKMapViewDelegate, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) Entity *entity;

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;

@end
