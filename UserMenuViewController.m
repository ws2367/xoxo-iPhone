//
//  UserMenuViewController.m
//  Cells
//
//  Created by WYY on 2013/11/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "UserMenuViewController.h"

@interface UserMenuViewController ()
@property (weak, nonatomic) BIDViewController *bidViewController;

@end

@implementation UserMenuViewController

- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
