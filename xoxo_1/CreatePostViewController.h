//
//  CreatePostViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDViewController;

@interface CreatePostViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
//    UIImageView *photo;
//    UIImagePickerController *picker;
}
    
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (nonatomic, retain) UIImagePickerController *picker;

@property (weak, nonatomic) IBOutlet UITextField *entitiesTextField;
@property (strong, nonatomic) NSMutableString *entityNames;
@property (strong, nonatomic) NSMutableArray *entities;

- (id)initWithBIDViewController:(BIDViewController *)viewController;


@end
