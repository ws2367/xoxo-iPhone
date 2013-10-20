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


@property (copy, nonatomic) NSString *pic;

- (id)initWithBIDViewController:(BIDViewController *)viewController;
@end
