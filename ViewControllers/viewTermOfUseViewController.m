//
//  viewTermOfUseViewController.m
//  Cells
//
//  Created by Iru on 4/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "viewTermOfUseViewController.h"
#import "NavigationController.h"

@interface viewTermOfUseViewController ()

@end

@implementation viewTermOfUseViewController

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
    [self addNavigationBar];
    [self addTermOfUse];
	// Do any additional setup after loading the view.
}


-(void) addNavigationBar{
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getMultiPostsContentFontDictionary]];
    [self.view addSubview:topNavigationBar];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    [exitButton setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-popular.png"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)];
    
    [exitButton setTintColor:[UIColor whiteColor]];
    
    //we want icon
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Yours"];
    
    UIImageView *yoursView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 80, 33)];
    [yoursView setImage:[UIImage imageNamed:@"logo_light.png"] ];
    yoursView.contentMode = UIViewContentModeScaleAspectFit;
    topNavigationItem.titleView = yoursView;
    
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationItem.leftBarButtonItem = homeButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Navigation Bar Button Methods
- (void)exitButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)homeButtonPressed:(id)sender{
    UIViewController *thisViewController = self;
    while (![thisViewController isKindOfClass:[NavigationController class]]) {
        thisViewController = [thisViewController presentingViewController];
    }
    [thisViewController dismissViewControllerAnimated:YES completion:nil];
}


-(void) addTermOfUse{
    UITextView *TOU = [[UITextView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_CUT_DOWN_HEIGHT, WIDTH, HEIGHT - NAVIGATION_BAR_CUT_DOWN_HEIGHT)];
    NSString* path = [[NSBundle mainBundle] pathForResource:@"OrrzsTermofUse" ofType:@"txt"];
    NSString* contentString = [NSString stringWithContentsOfFile:path
                                                  encoding:NSUTF8StringEncoding
                                                     error:NULL];
    NSAttributedString *content = [[NSAttributedString alloc] initWithString:contentString attributes:[Utility getViewPostDisplayCommentFontDictionary]];
    [TOU setAttributedText:content];
    [self.view addSubview:TOU];


}
@end
