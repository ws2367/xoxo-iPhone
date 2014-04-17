//
//  SettingViewController.m
//  Cells
//
//  Created by Iru on 3/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "SettingViewController.h"
#import "NavigationController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SettingViewController

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
    [_nameLabel setText:[(NavigationController *)self.navigationController getUserName]];
    [self addTopNavigationBar];
    [self.view setBackgroundColor:[UIColor colorForYoursWhite]];
    [self addSignOutButton];
    [self addLogo];
    [self addAdditionalButtons];
	// Do any additional setup after loading the view.
}

#pragma mark -
#pragma mark Add Button Methods
-(void) addTopNavigationBar{
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getNavigationBarTitleFontDictionary]];
    [topNavigationBar setShadowImage:[[UIImage alloc] init]];
    [topNavigationBar setBackgroundImage:[[UIImage alloc]init] forBarMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    [exitButton setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:@"Setting"];
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
    [self.view addSubview:topNavigationBar];
}

-(void) addSignOutButton{
    UIButton *signOutButton =[[UIButton alloc] initWithFrame:CGRectMake(0, HEIGHT - TABBAR_HEIGHT, WIDTH, TABBAR_HEIGHT)];
    [signOutButton setBackgroundColor:[UIColor colorForYoursFacebookBlue]];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"Log Out" attributes:[Utility getNavigationBarTitleFontDictionary]];
    [signOutButton setAttributedTitle:title forState:UIControlStateNormal];
    [signOutButton addTarget:self action:@selector(signOutButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:signOutButton];

}

-(void) addLogo{
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 85, WIDTH, 130)];
    [logoView setImage:[UIImage imageNamed:@"logo_org.png"]];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:logoView];
}

-(void)addAdditionalButtons{
    UIButton *termOfUseButton = [self addButtonAtY:250 withTitle:[NSString stringWithFormat:@"     Term of Use"]];
//    [termOfUseButton addTarget:self action:@selector(termOfUseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIButton *contactButton = [self addButtonAtY:250 + TABBAR_HEIGHT withTitle:[NSString stringWithFormat:@"     Contact Us"]];
//    [contactButton addTarget:self action:@selector(contactButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self addOrangeLineStartAtY:250+TABBAR_HEIGHT];
}

-(UIButton *)addButtonAtY:(CGFloat)Y withTitle:(NSString *)title{
    UIButton *button =[[UIButton alloc] initWithFrame:CGRectMake(0, Y, WIDTH, TABBAR_HEIGHT)];
    [button setBackgroundColor:[UIColor whiteColor]];
    NSAttributedString *titleString = [[NSAttributedString alloc] initWithString:title attributes:[Utility getSettingButtonFontDictionary]];
    [button setAttributedTitle:titleString forState:UIControlStateNormal];
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [self.view addSubview:button];
    return button;

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


#pragma sign out button pressed

- (IBAction)signOutButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure to sign out?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes",nil];
    [alertView show];
}

#pragma alertView delegate method
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [(NavigationController *)self.navigationController userLoggedOut];
            break;
        default:
            break;
    }
    
}

//#pragma mark - Prepare Segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}

-(void) addOrangeLineStartAtY:(CGFloat)offsetY{
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0.0f);
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(19, offsetY);
    CGPoint endPoint = CGPointMake(WIDTH, offsetY);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    
    UIColor *fill = [UIColor colorForYoursOrange];
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = fill.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    [self.view.layer addSublayer:dashLineLayer];
}



@end
