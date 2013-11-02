//
//  CreatePostViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDViewController;

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITableViewDelegate> {
    int photoIndex;
    UIImageView *currImageView;
    UIImageView *leftImageView;
    UIImageView *rightImageView;
//    UIImagePickerController *picker;
}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UIView *PostSuperImageView;
//@property (strong, nonatomic) UIImageView *currImageView;

@property (nonatomic, retain) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet UITextField *entitiesTextField;
@property (strong, nonatomic) NSMutableString *entityNames;
@property (strong, nonatomic) NSMutableArray *entities;
@property (strong, nonatomic) NSMutableArray *photos;
@property (strong, nonatomic) NSMutableString *content;


- (id)initWithBIDViewController:(BIDViewController *)viewController;

- (void)swipeImage:(UISwipeGestureRecognizer *)gesture;

- (void)textViewDidBeginEditing:(UITextView *) textView;

- (void) finishAddingEntity;

//Iru Test
- (void)receiveNSArray:(NSArray *)result;

@end
