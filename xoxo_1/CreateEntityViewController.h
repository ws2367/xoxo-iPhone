//
//  CreateEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDViewController;



@interface CreateEntityViewController : UIViewController <UITextFieldDelegate> 
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *institution;
@property (weak, nonatomic) IBOutlet UITextField *location;

- (id)initWithBIDViewController:(BIDViewController *)viewController;

@end
