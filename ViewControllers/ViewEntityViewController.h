//
//  ViewEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Entity.h"
#import "Post.h"
#import "BigPostTableViewCell.h"
#import "MultiplePeoplePickerViewController.h"
#import "MultiPostsTableViewController.h"

@interface ViewEntityViewController : UIViewController

@property (strong, nonatomic) Entity *entity;
@property (nonatomic, strong) Post *post;

@end
