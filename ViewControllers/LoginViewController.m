//
//  LoginViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/22/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "LoginViewController.h"
#import "ClientManager.h"

#import <FacebookSDK/FacebookSDK.h>

@interface LoginViewController ()
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation LoginViewController

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
    // Do any additional setup after loading the view.
    
    _loginView = [[FBLoginView alloc] initWithReadPermissions:@[@"basic_info", @"email", @"user_birthday"]];
    _loginView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    [self.nameLabel setText:user.name];
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    self.statusLabel.text = @"You'are logged in as";
    
    FBAccessTokenData *accessTokenData = FBSession.activeSession.accessTokenData;
    NSString *accessToken = accessTokenData.accessToken;

    NSLog(@"accessToken: %@", accessToken);
 
    [ClientManager login:accessToken];
    
}

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    self.statusLabel.text = @"You're logged out!";
    [self.nameLabel setText:@""];
    
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

#pragma mark - Navigation Controller delegate method
- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(willAppearIn:)])
        [viewController performSelector:@selector(willAppearIn:) withObject:navController];
}



#pragma mark - prepare for segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewMultiPostsSegue"]){
        UINavigationController *nav = segue.destinationViewController;
        nav.delegate = self;
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


@end
