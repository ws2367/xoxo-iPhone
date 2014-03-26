//
//  MultiPostsTabBarController.m
//  Cells
//
//  Created by WYY on 2014/3/23.
//  Copyright (c) 2014年 WYY. All rights reserved.
//

#import "MultiPostsTabBarController.h"
#import "MyPostsViewController.h"

@interface MultiPostsTabBarController ()
@property(strong,nonatomic) UIBarButtonItem * settingBtn;
@property(strong,nonatomic) UIBarButtonItem * searchBtn;
@end


@implementation MultiPostsTabBarController

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
    self.delegate = self;
    _settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStylePlain target:self action:@selector(mySettingButtonPressed:)];
    _searchBtn = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonPressed:)];
    self.navigationItem.leftBarButtonItem = _searchBtn;
	// Do any additional setup after loading the view.
}






#pragma mark - add center button
-(void)willAppearIn:(UINavigationController *)navigationController
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"camera_button_take.png"] highlightImage:nil];
}
// Create a custom UIButton and add it to the center of our tab bar
-(void) addCenterButtonWithImage:(UIImage*)buttonImage highlightImage:(UIImage*)highlightImage
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(0.0, 0.0, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [button setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    
    [button addTarget:self action:@selector(centerButtonTap:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = buttonImage.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}
#pragma mark - center button function
-(void)centerButtonTap:(id)sender{
    [self performSegueWithIdentifier:@"createPostSegue" sender:sender];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - detect which viewcontroller is selected right now
- (void)tabBarController:(UITabBarController *)tabBarController
 didSelectViewController:(UIViewController *)viewController{
    NSLog(@"everexecuted?");
    if([viewController isKindOfClass:MyPostsViewController.class]){
        self.navigationItem.rightBarButtonItem = _settingBtn;
    }
    else{
        self.navigationItem.rightBarButtonItem = NULL;
    }
}

- (void)mySettingButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"viewMySettingSegue" sender:sender];
}

- (void)searchButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"searchSegue" sender:sender];
}


//#pragma mark - Prepare Segue
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//// Get the new view controller using [segue destinationViewController].
//// Pass the selected object to the new view controller.
//}

@end
