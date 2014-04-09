//
//  ViewPostViewController.h
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"
#import <AddressBookUI/AddressBookUI.h>
#import "ViewPostDisplayButtonBarTableViewCell.h"

@class ViewMultiPostsViewController;

@interface ViewPostViewController : UIViewController
                                <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate, ABPeoplePickerNavigationControllerDelegate,ViewPostDisplayButtonBarTableViewCellDelegate,UIActionSheetDelegate>



- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;
- (void) setPost:(Post *)post;
- (void) setStartEditingComment:(BOOL)shouldStartEdit;
@end
