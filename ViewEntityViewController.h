//
//  ViewEntityViewController.h
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XOXOUIViewController.h"

@class BIDViewController;

@interface ViewEntityViewController : XOXOUIViewController

- (id)initWithBIDViewController:(BIDViewController *)viewController;
- (void)setEntityName:(NSString *)entityName;

@end
