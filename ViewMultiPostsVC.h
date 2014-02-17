//
//  ViewMultiPostsVC.h
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

@interface ViewMultiPostsVC : XOXOUIViewController
        <UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) NSMutableArray *posts;

@property (strong, nonatomic) NSMutableArray *entities;

//These are all user actions that involves switching view controllers
- (void)finishCreatingEntityStartCreatingPost;
- (void)finishCreatingPostBackToHomePage;
- (void)cancelCreatingEntity;
- (void)cancelCreatingPost;
- (void)cancelViewingPost;
- (void)cancelViewingEntity;
- (void)beginSearchTakeOverWindow;
- (void)endSearchTakeOverWindow;

@end
