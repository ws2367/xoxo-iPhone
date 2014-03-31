//
//  CreatePostViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FacebookSDK/FacebookSDK.h"

@class ViewMultiPostsViewController;
@class Entity;

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate, UITextViewDelegate, FBFriendPickerDelegate>

@property (strong, nonatomic) NSMutableArray *entities;

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;

-(void) addEntity:(Entity *)en;

@end
