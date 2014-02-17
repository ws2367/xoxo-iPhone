//
//  ViewEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "XOXOUIViewController.h"

@class ViewMultiPostsViewController;

@interface ViewEntityViewController : XOXOUIViewController
                                        <MKMapViewDelegate>

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;
- (void)setEntityName:(NSString *)entityName;

@end
