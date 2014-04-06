//
//  ViewPostViewController.h
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Post.h"

@class ViewMultiPostsViewController;

@interface ViewPostViewController : UIViewController
                                <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate>



- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController;
- (void) setPost:(Post *)post;
@end
