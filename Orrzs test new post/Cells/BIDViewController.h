//
//  BIDViewController.h
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NewPostViewController;
@class CreatePostViewController;

@interface BIDViewController : UIViewController
        <UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSArray *posts;
@property (strong, nonatomic) NewPostViewController *postController;
@property (strong, nonatomic) CreatePostViewController *createPostController;
@property (strong, nonatomic) NSMutableArray *entities;

@end
