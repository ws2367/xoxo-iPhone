//
//  BIDViewController.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "XOXOUIViewController.h"

@class CreateEntityViewController;
@class CreatePostViewController;

@interface BIDViewController : XOXOUIViewController
        <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (copy, nonatomic) NSArray *posts;

@property (strong, nonatomic) NSMutableArray *entities;

- (void)finishCreatingEntityStartCreatingPost;
- (void)finishCreatingPostBackToHomePage;
- (void)cancelCreatingEntity;
- (void)cancelCreatingPost;
- (void)cancelViewingPost;
- (void)cancelViewingEntity;

@end
