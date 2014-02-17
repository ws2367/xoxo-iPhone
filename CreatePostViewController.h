//
//  CreatePostViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMultiPostsVC;

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *entities;

- (id)initWithViewMultiPostsVC:(ViewMultiPostsVC *)viewController;

- (void)swipeImage:(UISwipeGestureRecognizer *)gesture;

- (void)textViewDidBeginEditing:(UITextView *) textView;

- (void) finishAddingEntity;

//Iru Test
- (void)receiveNSArray:(NSArray *)result;

@end
