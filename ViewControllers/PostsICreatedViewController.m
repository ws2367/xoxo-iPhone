//
//  PostsICreatedViewController.m
//  Cells
//
//  Created by Iru on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "PostsICreatedViewController.h"

@interface PostsICreatedViewController ()

@end

@implementation PostsICreatedViewController

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
    UIImage *userImage = [UIImage imageNamed:@"YoursIcon2nd40x40.png"];
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:userImage];
    [userImageView setFrame:CGRectMake(10, 0, userImage.size.width, userImage.size.height)];
    [self.view addSubview:userImageView];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
