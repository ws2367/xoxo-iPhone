//
//  LoginViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/22/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "LoginViewController.h"
#import "ClientManager.h"
#import "NavigationController.h"
#import "UIColor+MSColor.h"

#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UILabel *youAreLoggedInLabel;
@property (strong, nonatomic) UILabel *youAreLoggedOutLabel;
@property (strong, nonatomic) UILabel *displayNameLabel;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_birthday", @"friends_education_history",@"friends_work_history"]];
    _loginView.delegate = self;
    [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    [self addLogo];
    [self addDescriptionsWithString:@"Welcome to Yours" atX:90 andY:300 withDictionary:[Utility getLoginViewTitleDescriptionFontDictionary]];
    [self addDescriptionsWithString:@"A place to say your true opinions" atX:60 andY:330 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    [self addDescriptionsWithString:@"You will always be anonymous on Yours" atX:30 andY:350 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    _displayNameLabel = [self addDescriptionsWithString:user.name atX:120 andY:410 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [_youAreLoggedOutLabel removeFromSuperview];
    _youAreLoggedInLabel = [self addDescriptionsWithString:@"You'are logged in as" atX:88 andY:390 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    FBAccessTokenData *accessTokenData = FBSession.activeSession.accessTokenData;
    NSString *FBAccessToken = accessTokenData.accessToken;

    MSDebug(@"FB Access Token: %@", FBAccessToken);

    [ClientManager login:FBAccessToken delegate:self];
}

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    [_youAreLoggedInLabel removeFromSuperview];
    [_displayNameLabel removeFromSuperview];
    _youAreLoggedOutLabel = [self addDescriptionsWithString:@"You're logged out!" atX:88 andY:390 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    
    [ClientManager logout];
}

// Handle possible errors that can occur during login
- (void)loginView:(FBLoginView *)loginView handleError:(NSError *)error {
    NSString *alertMessage, *alertTitle;
    
    // If the user should perform an action outside of you app to recover,
    // the SDK will provide a message for the user, you just need to surface it.
    // This conveniently handles cases like Facebook password change or unverified Facebook accounts.
    if ([FBErrorUtility shouldNotifyUserForError:error]) {
        alertTitle = @"Facebook error";
        alertMessage = [FBErrorUtility userMessageForError:error];
        
        // This code will handle session closures that happen outside of the app
        // You can take a look at our error handling guide to know more about it
        // https://developers.facebook.com/docs/ios/errors
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
        alertTitle = @"Session Error";
        alertMessage = @"Your current session is no longer valid. Please log in again.";
        
        // If the user has cancelled a login, we will do nothing.
        // You can also choose to show the user a message if cancelling login will result in
        // the user not being able to complete a task they had initiated in your app
        // (like accessing FB-stored information or posting to Facebook)
    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
        NSLog(@"user cancelled login");
        
        // For simplicity, this sample handles other errors with a generic message
        // You can checkout our error handling guide for more detailed information
        // https://developers.facebook.com/docs/ios/errors
    } else {
        alertTitle  = @"Something went wrong";
        alertMessage = @"Please try again later.";
        NSLog(@"Unexpected error:%@", error);
    }
    
    if (alertMessage) {
        [[[UIAlertView alloc] initWithTitle:alertTitle
                                    message:alertMessage
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark -
#pragma mark TVMClient Delegate methods
- (void) TVMLoggedIn
{
    [self performSegueWithIdentifier:@"viewMultiPostsSegue" sender:nil];
}

- (void) TVMLoggingInFailed
{
    [self logoutUser];
}



#pragma mark - Navigation Controller delegate method
- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(willAppearIn:)])
        [viewController performSelector:@selector(willAppearIn:) withObject:navController];
}


#pragma mark - log out user method
-(void) logoutUser{
    [_displayNameLabel removeFromSuperview];
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - prepare for segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewMultiPostsSegue"]){
        NavigationController *nav = segue.destinationViewController;
        nav.delegate = self;
        [nav setUserName:[_displayNameLabel text]];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark --
#pragma mark - UI Method
-(void) addLogo{
    UIImage *logoImage = [UIImage imageNamed:@"logo_white.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    [logoImageView setFrame:CGRectMake(24, 113, logoImage.size.width, logoImage.size.height)];
    [self.view addSubview:logoImageView];
}

-(UILabel *) addDescriptionsWithString:(NSString *)stringToDisplay atX:(CGFloat)originX andY:(CGFloat)originY withDictionary:(NSDictionary *)dictionary{
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:stringToDisplay attributes:dictionary];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(originX, originY, WIDTH, 20)];
    [textLabel setAttributedText:text];
    [self.view addSubview:textLabel];
    return textLabel;
}


@end
