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

@class ViewMultiPostsVC;

@interface ViewEntityViewController : XOXOUIViewController
                                        <MKMapViewDelegate>

- (id)initWithViewMultiPostsVC:(ViewMultiPostsVC *)viewController;
- (void)setEntityName:(NSString *)entityName;

@end
