//
//  MyPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "MyPostsViewController.h"
#import "PostsAboutMeViewController.h"
#import "PostsICreatedViewController.h"
#import "NavigationController.h"
#import "ViewEntityViewController.h"
#import "ViewPostViewController.h"
#import "NavigationController.h"

#import "KeyChainWrapper.h"

#import "UIColor+MSColor.h"

#define CONTENT_VIEW_BEGIN_Y 110
#define BUTTON_TAG_OFFSET 1000

@interface MyPostsViewController ()

@property (strong, nonatomic) NSArray *viewControllers;
@property (strong, nonatomic) UIView *tabButtonsContainerView;
@property (strong, nonatomic) UIView *contentContainerView;
@property (nonatomic) NSUInteger selectedIndex;
@property (strong, nonatomic) UIViewController *selectedViewController;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) UINavigationItem *topNavigationItem;


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
    [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    [self addTopNavigationBar];
    NSLog(@"loaded my posts");
    [self setupTabSystem];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) addTopNavigationBar{
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getMultiPostsContentFontDictionary]];
    [topNavigationBar setShadowImage:[[UIImage alloc] init]];
    [topNavigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];

    UIBarButtonItem *settingButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-setting.png"] style:UIBarButtonItemStylePlain target:self action:@selector(settingButtonPressed:)];
    [settingButton setTintColor:[UIColor whiteColor]];
    
    _userName = [(NavigationController *)self.navigationController getUserName];
    if(_userName == nil || [_userName isEqualToString:@""]){
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                // Success! Include your code to handle the results here
                _userName = [result objectForKey:@"name"];
                [_topNavigationItem setTitle:_userName];
                NSLog(@"user info: %@", result);
            } else {
                // An error occurred, we need to handle the error
                // See: https://developers.facebook.com/docs/ios/errors
            }
        }];
    }
    _topNavigationItem = [[UINavigationItem alloc] initWithTitle:_userName];
    
    
    _topNavigationItem.rightBarButtonItem = settingButton;
    topNavigationBar.items = [NSArray arrayWithObjects: _topNavigationItem,nil];
    [self.view addSubview:topNavigationBar];


}
#pragma mark -
#pragma mark Button Method
-(void)settingButtonPressed:(id)sender{
    MSDebug(@"Setting Button Pressed");
    [self performSegueWithIdentifier:@"viewSettingSegue" sender:sender];
}


#pragma mark -
#pragma mark Imitate TabBar System
-(void) setupTabSystem{
    PostsAboutMeViewController *postsAboutMeViewController = [[PostsAboutMeViewController alloc] initWithStyle:UITableViewStylePlain];

    PostsICreatedViewController *postsICreatedViewController = [[PostsICreatedViewController alloc] initWithStyle:UITableViewStylePlain];
    _viewControllers = @[postsAboutMeViewController, postsICreatedViewController];
    postsAboutMeViewController.tabBarItem.title = @"Posts About Me";
    postsAboutMeViewController.myPostsViewController = self;
    
    postsICreatedViewController.tabBarItem.title = @"My Posts";
    postsICreatedViewController.myPostsViewController = self;
    
	_tabButtonsContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CONTENT_VIEW_BEGIN_Y - MY_POST_TABBAR_HEIGHT, self.view.bounds.size.width, MY_POST_TABBAR_HEIGHT)];
	_tabButtonsContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	[self.view addSubview:_tabButtonsContainerView];
    
    [self addWhiteLineAtY:CONTENT_VIEW_BEGIN_Y - MY_POST_TABBAR_HEIGHT];
    
	_contentContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, CONTENT_VIEW_BEGIN_Y, WIDTH, HEIGHT - CONTENT_VIEW_BEGIN_Y - MY_POST_TABBAR_HEIGHT)];
    
    [_contentContainerView setBackgroundColor:[UIColor colorForYoursOrange]];
    
    _selectedIndex = BUTTON_TAG_OFFSET + 0;
    _selectedViewController = [_viewControllers objectAtIndex:0];
	[self.view addSubview:_contentContainerView];

    [self reloadTabButtons];
    [self setSelectedIndex:BUTTON_TAG_OFFSET + 0];
}

-(void) reloadTabButtons{
    [self removeTabButtons];
	[self addTabButtons];
}

-(void)addTabButtons{
    NSUInteger index = BUTTON_TAG_OFFSET;
	for (UIViewController *viewController in _viewControllers){
        CGRect buttonRect;
        if(index == BUTTON_TAG_OFFSET){
            buttonRect = CGRectMake(0, 0, WIDTH/2, TABBAR_HEIGHT);
        } else{
            buttonRect = CGRectMake(WIDTH/2, 0, WIDTH/2, TABBAR_HEIGHT);
        }
		UIButton *button = [[UIButton alloc] initWithFrame:buttonRect];
		button.tag = index;
		[button setTitle:viewController.tabBarItem.title forState:UIControlStateNormal];
        
		[button addTarget:self action:@selector(tabButtonPressed:) forControlEvents:UIControlEventTouchDown];
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16.0];
        [self deselectTabButton:button];
		[_tabButtonsContainerView addSubview:button];
        
		++index;
	}
}

- (void)tabButtonPressed:(UIButton *)sender
{
	[self setSelectedIndex:sender.tag];
}


-(void) deselectTabButton:(UIButton *)button{
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorForYoursOrange]];
    MSDebug(@"im deselecting button %ld", (long)button.tag);
}

- (void) selectTabButton:(UIButton *)button
{
    [button setTitleColor:[UIColor colorForYoursOrange] forState:UIControlStateNormal];
	[button setBackgroundColor:[UIColor whiteColor]];
}


- (void)removeTabButtons
{
	while ([_tabButtonsContainerView.subviews count] > 0)
	{
		[[_tabButtonsContainerView.subviews lastObject] removeFromSuperview];
	}
}

- (void)setSelectedIndex:(NSUInteger)newSelectedIndex{
	NSAssert(newSelectedIndex < BUTTON_TAG_OFFSET + [self.viewControllers count], @"View controller index out of bounds");

    UIViewController *fromViewController;
    UIViewController *toViewController;
    
    if (_selectedIndex != NSNotFound)
    {
        UIButton *fromButton = (UIButton *)[_tabButtonsContainerView viewWithTag:_selectedIndex];
        [self deselectTabButton:fromButton];
        MSDebug(@"deselect %ld",(long)fromButton.tag);
        fromViewController = [_viewControllers objectAtIndex:_selectedIndex - BUTTON_TAG_OFFSET];
    }
    
    
    UIButton *toButton;
    if (_selectedIndex != NSNotFound)
    {
        toButton = (UIButton *)[_tabButtonsContainerView viewWithTag: newSelectedIndex];
        MSDebug(@"select %ld",(long)toButton.tag);
        [self selectTabButton:toButton];
        MSDebug(@"select %ld",(long)toButton.tag);
        toViewController = [_viewControllers objectAtIndex:newSelectedIndex - BUTTON_TAG_OFFSET];
        
    }
    
    _selectedIndex = newSelectedIndex;

    
    if (toViewController == nil)  // don't animate
    {
        [fromViewController.view removeFromSuperview];
    }
    else if (fromViewController == nil)  // don't animate
    {
        toViewController.view.frame = _contentContainerView.bounds;
        [_contentContainerView addSubview:toViewController.view];
    } else{
        MSDebug(@"changed view");
        [fromViewController.view removeFromSuperview];
        
        toViewController.view.frame = _contentContainerView.bounds;
        
        [_contentContainerView addSubview:toViewController.view];

    }
}

#pragma mark -
#pragma mark Segue methods
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        if ([sender isKindOfClass:[Post class]]) {
            [Flurry logEvent:@"View_Post" withParameters:@{@"View":@"Notification"}];
            [nextController setPost:(Post *)sender];
            
        } else {
            [Flurry logEvent:@"View_Post" withParameters:@{@"View":@"MyPosts"}];

            if (!_post) {
                MSError(@"No post is set when performing viewPostSegue");
            }
            [nextController setPost:_post];
            if ([sender tag] == 0) {
                [nextController setStartEditingComment:NO];
            }else{
                [nextController setStartEditingComment:YES];
            }
        }
    } else if([segue.identifier isEqualToString:@"viewSettingSegue"]){
        //do nothing
    }
}

#pragma mark -
#pragma mark UI methods
-(void) addWhiteLineAtY:(CGFloat)offsetY{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0f);
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(0, offsetY);
    CGPoint endPoint = CGPointMake(WIDTH, offsetY);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    
    UIColor *fill = [UIColor whiteColor];
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = fill.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    [self.view.layer addSublayer:dashLineLayer];
}

#pragma mark -
#pragma mark Let CreatePost switch and scroll methods
-(void) switchToMyPostsAndScrollToPost:(Post *)post{
    [self setSelectedIndex:BUTTON_TAG_OFFSET + 1];
    [self scrollContentContainerViewToPost:post];
}
# pragma mark -
#pragma mark ScrollToEnd helper method
- (void)scrollContentContainerViewToPost:(Post *)post{
//    CGFloat yOffset = 0;
    UITableViewController *postsICreatedVC = [_viewControllers objectAtIndex:1];
//    MSDebug(@"whats up %@", postsICreatedVC.tableView);
//    MSDebug(@"%f and %f", postsICreatedVC.tableView.contentSize.height, postsICreatedVC.tableView.bounds.size.height);
//    if (postsICreatedVC.t
//        postsICreatedVC.tableView.contentSize.height > postsICreatedVC.tableView.bounds.size.height) {
//        yOffset = postsICreatedVC.tableView.contentSize.height - postsICreatedVC.tableView.bounds.size.height;
//    }
    ((PostsICreatedViewController *)postsICreatedVC).postToScrollTo = post;
//    [postsICreatedVC.tableView setContentOffset:CGPointMake(0, 100) animated:NO];
}


@end
