//
//  MyPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "MyPostsViewController.h"

@interface MyPostsViewController ()

@end

@implementation MyPostsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(mySettingButtonPressed:)];
    self.navigationItem.rightBarButtonItem = settingBtn;
    NSLog(@"loaded my posts");
    
}

- (void)mySettingButtonPressed:(id)sender{
    NSLog(@"mySettingButtonPressed");
    [self performSegueWithIdentifier:@"viewMySettingSegue" sender:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end