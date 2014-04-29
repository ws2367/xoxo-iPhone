//
//  navigationController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/13/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "NavigationController.h"
#import "LoginViewController.h"

#import "KeyChainWrapper.h"

@interface NavigationController ()
@property(strong, nonatomic)NSString *userName;

@end

@implementation NavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationBar.shadowImage = [UIImage new];
    self.navigationBar.translucent = YES;
    
    [self.navigationBar setTintColor:[UIColor orangeColor]];
}

-(void) viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    
    // need to put in viewDidAppear not viewWillAppear, because it will overwrite the size.
    // although we see that it zoom to full size then to our customized size, since its
    // translucent, we leave it this way.
    [self.navigationBar setFrame:CGRectMake(0, 0, NAVIGATION_BAR_CUT_DOWN_HEIGHT, NAVIGATION_BAR_CUT_DOWN_HEIGHT)];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) userLogOut{
    [(LoginViewController *)self.delegate logoutUser];
    [KeyChainWrapper cleanUpCredentials];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) setUserName:(NSString *)userName{
    _userName = userName;
}

-(NSString *) getUserName{
    return _userName;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
