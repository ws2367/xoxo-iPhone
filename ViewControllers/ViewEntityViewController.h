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
#import "BigPostTableViewCell.h"
#import "MultiplePeoplePickerViewController.h"
#import <AddressBookUI/AddressBookUI.h>

@class ViewMultiPostsViewController;

@interface ViewEntityViewController : UIViewController
                                        <NSFetchedResultsControllerDelegate, BigPostTableViewCellDelegate, UIActionSheetDelegate,
                                        MultiplePeoplePickerViewControllerDelegate>

@property (strong, nonatomic) Entity *entity;


@end
