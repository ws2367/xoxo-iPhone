//
//  ViewPostViewController.h
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BIDViewController;

@interface ViewPostViewController : UIViewController
                                <UITableViewDelegate, UITableViewDataSource>

@property (copy, nonatomic) NSString *pic;
@property (strong, nonatomic) NSString *content;

- (id)initWithBIDViewController:(BIDViewController *)viewController;

@end
