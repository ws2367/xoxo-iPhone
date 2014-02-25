//
//  ViewMultiPostsViewController.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Post.h"
#import "Entity.h"

@class CreateEntityViewController;
@class CreatePostViewController;

@interface ViewMultiPostsViewController : UIViewController
        <UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate>

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

//TODO: depreciate it after implementing Core Data
@property (strong, nonatomic) NSMutableArray *entities;

//These are all user actions that involves switching view controllers
- (void)finishCreatingEntityStartCreatingPost;
- (void)finishCreatingPostBackToHomePage;
- (void)cancelCreatingEntity;
- (void)cancelCreatingPost;
- (void)cancelViewingPost;
- (void)cancelViewingEntity;
- (void)startViewingPostForPost:(Post *)post;
- (void)startViewingEntityForEntity:(Entity *)entity;
- (void)beginSearchTakeOverWindow;
- (void)endSearchTakeOverWindow;

-(void)sharePost;
@end
