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

#import <AWSRuntime/AWSRuntime.h>

@class CreateEntityViewController;
@class CreatePostViewController;

@interface ViewMultiPostsViewController : UIViewController
        <UINavigationControllerDelegate, ABPeoplePickerNavigationControllerDelegate, AmazonServiceRequestDelegate>

//TODO: depreciate it after implementing Core Data
@property (strong, nonatomic) NSMutableArray *entities;

//These are all user actions that involves switching view controllers


- (void)cancelCreatingEntity;
- (void)cancelCreatingPost;
- (void)cancelViewingPost;
- (void)cancelViewingEntity;
- (void)startViewingPostForPost:(Post *)post;
- (void)startViewingEntityForEntity:(Entity *)entity;

-(void)sharePost;
@end
