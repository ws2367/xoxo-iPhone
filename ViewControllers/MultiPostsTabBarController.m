//
//  MultiPostsTabBarController.m
//  Cells
//
//  Created by WYY on 2014/3/23.
//  Copyright (c) 2014年 WYY. All rights reserved.
//

#import "MultiPostsTabBarController.h"
#import "MyPostsViewController.h"
#import "UIColor+MSColor.h"
#import "CreatePostViewController.h"



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
    //delete setting button from here, add it in mypost
    /*_settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Setting" style:UIBarButtonItemStylePlain target:self action:@selector(mySettingButtonPressed:)];
     */
    _searchBtn = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(searchButtonPressed:)];
//    self.navigationItem.leftBarButtonItem = _searchBtn;
    [_searchBtn setTintColor:[UIColor colorForTabBar]];
    
    //we dont need any navigationcontroller anymore
    [self.navigationController.navigationBar removeFromSuperview];
    
    //set tabbar background color
    CGRect frame = CGRectMake(0.0, 0.0, self.view.bounds.size.width, TABBAR_HEIGHT );
    UIView *v = [[UIView alloc] initWithFrame:frame];
    [v setBackgroundColor:[UIColor colorForTabBar]];
    [v setAlpha:1];
    [[self tabBar] insertSubview:v atIndex:0];
    
    //set upper orange area
    CGRect upperframe = CGRectMake(0.0, 0.0, self.view.bounds.size.width, UPPER_AREA_HEIGHT);
    UIView *up = [[UIView alloc] initWithFrame:upperframe];
    [up setBackgroundColor:[UIColor colorForTabBar]];
    [up setAlpha:1];
    [self.view addSubview:up];

    //set tabbar frame
    self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - TABBAR_HEIGHT, WIDTH, TABBAR_HEIGHT);
    
    // delete the shadow line on top of tabbar
    [self.tabBar setShadowImage:[[UIImage alloc] init]];
    [self.tabBar setBackgroundImage:[[UIImage alloc] init]];
    
    //set image color to white
    [self.tabBar setTintColor:[UIColor whiteColor]];
//    [self.customizableViewControllers
	// Do any additional setup after loading the view.
    
    //set tabbaritem image
    [self setTabBarItemImages];
    // set tabbaritem font
    for(UIViewController *v in self.customizableViewControllers){
        [v.tabBarItem setTitleTextAttributes:[Utility getTabBarItemUnselectedFontDictionary] forState:UIControlStateNormal];
        [v.tabBarItem setTitleTextAttributes:[Utility getTabBarItemSelectedFontDictionary] forState:UIControlStateHighlighted];
        v.tabBarItem.image = [v.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        v.tabBarItem.selectedImage = [v.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];

    }

    
//    [firstVC.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"menu-popular.png"] withFinishedUnselectedImage:[UIImage imageNamed:@"menu-popular-unselected.png"]];
    //[firstVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu-popular.png"]];
    
//    self.tabBarItem = [self.tabBarController.tabBar.items objectAtIndex:0];
//    [self.tabBarItem setImage:[UIImage imageNamed:@"menu-popular-unselected.png"]];
//    self.tabBarItem.selectedImage = [UIImage imageNamed:@"menu-popular.png"];
}

#pragma mark - UI methods
-(void) setTabBarItemImages{

    UIViewController *firstVC = [self.customizableViewControllers objectAtIndex:0];
    [firstVC.tabBarItem setImage:[UIImage imageNamed:@"menu-popular-unselected.png"]];
    [firstVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu-popular.png"]];
    UIViewController *secondVC = [self.customizableViewControllers objectAtIndex:1];
    [secondVC.tabBarItem setImage:[UIImage imageNamed:@"menu-friends-unselected.png"]];
    [secondVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu-friends.png"]];
    UIViewController *fourthVC = [self.customizableViewControllers objectAtIndex:3];
    [fourthVC.tabBarItem setImage:[UIImage imageNamed:@"menu-favorites-unselected.png"]];
    [fourthVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu-favorites.png"]];
    UIViewController *fifthVC = [self.customizableViewControllers objectAtIndex:4];
    [fifthVC.tabBarItem setImage:[UIImage imageNamed:@"menu-my-unselected.png"]];
    [fifthVC.tabBarItem setSelectedImage:[UIImage imageNamed:@"menu-my.png"]];
}

#pragma mark - add center button
-(void)willAppearIn:(UINavigationController *)navigationController
{
    [self addCenterButtonWithImage:[UIImage imageNamed:@"menu-addpost.png"] highlightImage:nil];

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
    [Flurry logEvent:@"Create_Post" withParameters:@{@"View":@"MultiPosts"} timed:YES];
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
//    if([viewController isKindOfClass:MyPostsViewController.class]){
//        //dont add it in here, add it in my post
//        //self.navigationItem.rightBarButtonItem = _settingBtn;
//        [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, WIDTH, NAVIGATION_BAR_CUT_DOWN_HEIGHT)];
//    }
//    else{
//        self.navigationItem.rightBarButtonItem = NULL;
//        [self.navigationController.navigationBar setFrame:CGRectMake(0, 0, NAVIGATION_BAR_CUT_DOWN_HEIGHT, NAVIGATION_BAR_CUT_DOWN_HEIGHT)];
//    }
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if([segue.identifier isEqualToString:@"createPostSegue"]){
        CreatePostViewController *viewController = segue.destinationViewController;
        viewController.multiPostsTabBarController = self;
    }
}

#pragma mark -
#pragma mark Let CreatePost change view Method
- (void) createPostsViewControllerWantsToSwitchAndScrollToPost:(Post *)post{
    [self setSelectedIndex:4];
    UIViewController *myPostVC = [self.customizableViewControllers objectAtIndex:4];
    if(myPostVC){
        if([myPostVC isKindOfClass:[MyPostsViewController class]]){
            [(MyPostsViewController *)myPostVC switchToMyPostsAndScrollToPost:post];
        }
    }
}


@end
