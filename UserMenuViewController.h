//
//  UserMenuViewController.h
//  Cells
//
//  Created by WYY on 2013/11/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewMultiPostsViewController;
@interface UserMenuViewController : UIViewController
                                    <UISearchBarDelegate, UITextFieldDelegate>

- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;

@end
