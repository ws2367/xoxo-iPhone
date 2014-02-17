//
//  CreateEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMultiPostsVC;
@class CreatePostViewController;
@class Entity;


@interface CreateEntityViewController : UIViewController <UITextFieldDelegate> 

@property(strong, nonatomic) Entity *selectedEntity;

- (id)initWithViewMultiPostsVC:(ViewMultiPostsVC *)viewController;

- (id)initWithCreatePostViewController:(CreatePostViewController *)viewController;
- (void)dismissBlackMask;

@end
