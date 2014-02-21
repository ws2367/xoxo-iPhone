//
//  CreatePostViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMultiPostsViewController;

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *entities;

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;

- (void) finishAddingEntity;

@end
