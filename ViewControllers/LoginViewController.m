//
//  LoginViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/22/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>

#import "LoginViewController.h"
#import "NavigationController.h"

#import "ClientManager.h"
#import "KeyChainWrapper.h"

#import "UIColor+MSColor.h"

#define NAME_LOGINOUT_TAG 4321

@interface LoginViewController ()
@property (strong, nonatomic) FBLoginView *loginView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) UILabel *youAreLoggedInLabel;
@property (strong, nonatomic) UILabel *youAreLoggedOutLabel;
@property (strong, nonatomic) UILabel *displayNameLabel;
@property (strong, nonatomic) NSString *userName;

@property (retain, nonatomic) FBFriendPickerViewController *friendPickerController;

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
    if(self.view.bounds.size.height > HEIGHT_TO_DISCRIMINATE){
        [_loginView setFrame:CGRectMake(34, 430,253, 46)];
    }else{
        [_loginView setFrame:CGRectMake(34, 430-50,253, 46)];
    }
    [self.view addSubview:_loginView];
    [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    [self addLogo];
    [self addDescriptionsWithString:@"Welcome to Yours" andY:300 withDictionary:[Utility getLoginViewTitleDescriptionFontDictionary]];
    [self addDescriptionsWithString:@"A place to say your true opinions" andY:330 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    [self addDescriptionsWithString:@"You will always be anonymous on Yours" andY:350 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];


}

-(void)viewDidAppear:(BOOL)animated{

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user{
    _userName = [user.name copy];
    _displayNameLabel = [self addDescriptionsWithString:user.name andY:405 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    [_displayNameLabel setTag:NAME_LOGINOUT_TAG];
}

- (void) loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    [_youAreLoggedOutLabel removeFromSuperview];
    _youAreLoggedInLabel = [self addDescriptionsWithString:@"You'are logged in as" andY:385 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    [_youAreLoggedInLabel setTag:NAME_LOGINOUT_TAG];
    FBAccessTokenData *accessTokenData = FBSession.activeSession.accessTokenData;
    NSString *FBAccessToken = accessTokenData.accessToken;

    MSDebug(@"FB Access Token: %@", FBAccessToken);

    [ClientManager login:FBAccessToken delegate:self];
}

- (void) loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    for(UIView *view in self.view.subviews){
        if(view.tag == NAME_LOGINOUT_TAG){
            [view removeFromSuperview];
        }
    }
    _youAreLoggedOutLabel = [self addDescriptionsWithString:@"You're logged out!" andY:390 withDictionary:[Utility getLoginViewContentDescriptionFontDictionary]];
    [_youAreLoggedOutLabel setTag:NAME_LOGINOUT_TAG];
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
    //Set Badge number to 0
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ClientManager sendBadgeNumber:0];
    });
    [self performSegueWithIdentifier:@"viewMultiPostsSegue" sender:nil];
}

- (void) TVMLoggingInFailed
{
    [self logoutFBUser];
}

- (void) TVMSignedUp
{
    [Flurry logEvent:@"Signed_Up"];
    //Set Badge number to 0
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [ClientManager sendBadgeNumber:0];
    });
    [self performSegueWithIdentifier:@"viewMultiPostsSegue" sender:nil];
}

/*
- (void) TVMSignedUp
{
    //if we want user to login directly, uncomment this line of code. [self performSegueWithIdentifier:@"viewMultiPostsSegue" sender:nil];

    // if the session is open, then load the data for our view controller
    if (!FBSession.activeSession.isOpen) {
        MSDebug(@"no session");
        // if the session is closed, then we open it here, and establish a handler for state changes
        NSArray *permissions = [[NSArray alloc] initWithObjects:
                                @"user_birthday", @"friends_hometown", @"email",
                                @"friends_birthday", @"friends_location", @"friends_education_history", nil];
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState state,
                                                          NSError *error) {
                                          if (error) {
                                              UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                                  message:error.localizedDescription
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"OK"
                                                                                        otherButtonTitles:nil];
                                              [alertView show];
                                          } else if (session.isOpen) {
                                              [self TVMSignedUp];
                                          }
                                      }];
        return;
    }
    
    
    //removed who invited you friendPicker...
    
    if (self.friendPickerController == nil) {
        // Create friend picker, and get data loaded into it.
        self.friendPickerController = [[FBFriendPickerViewController alloc] init];
        self.friendPickerController.title = @"Who invited you?";
        [self.friendPickerController setAllowsMultipleSelection:NO];
        self.friendPickerController.delegate = self;
    }
    
    [self.friendPickerController loadData];
    [self.friendPickerController clearSelection];
    
    [self presentViewController:self.friendPickerController animated:YES completion:nil];
     
}

# pragma mark -
#pragma mark - FBFriendPickerDelegate method
- (void)facebookViewControllerDoneWasPressed:(id)sender {
    id<FBGraphUser> frd = [self.friendPickerController.selection firstObject];
    [self dismissViewControllerAnimated:YES completion:^{
        [self performSegueWithIdentifier:@"viewMultiPostsSegue" sender:nil];
    }];
    [self processFBUser:frd];
}

- (void)facebookViewControllerCancelWasPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)processFBUser:(id<FBGraphUser>)frd{
    FBRequest *request = [[FBRequest alloc] initWithSession:FBSession.activeSession
                                                  graphPath:frd.id];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSString *name = [result objectForKey:@"name"];
            NSString *birthday = [result objectForKey:@"birthday"];
            NSString *fbID = frd.id;
            MSDebug(@"name: %@, birthday: %@, fb ID: %@", name, birthday, fbID);
            
            if (![KeyChainWrapper isSessionTokenValid]) {
                MSError(@"User session token is not valid.");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Utility generateAlertWithMessage:@"You're not logged in!" error:nil];
                });
                return;
            }
            
            if (fbID == nil) {
                MSError(@"No fb ID in reporting inviter");
                return;
            }
            
            NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
            
            NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjects:@[sessionToken, fbID]
                                                                              forKeys:@[@"auth_token", @"fb_id"]];
            
            if (name) {[params setObject:name forKey:@"name"];}
            if (birthday) {[params setObject:birthday forKey:@"birthday"];}
            
            NSMutableURLRequest *request = [[RKObjectManager sharedManager] requestWithPathForRouteNamed:@"report_inviter"
                                                                             object:self
                                                                         parameters:params];
            
            RKHTTPRequestOperation *operation = [[RKHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:nil
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                 [Utility generateAlertWithMessage:@"Network problem" error:error];
                                                 MSError(@"Cannot report inviter!");
                                             }];
            
            NSOperationQueue *operationQueue = [NSOperationQueue new];
            [operationQueue addOperation:operation];
            
        });
    }];
}

*/

#pragma mark - Navigation Controller delegate method
- (void)navigationController:(UINavigationController *)navController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([viewController respondsToSelector:@selector(willAppearIn:)])
        [viewController performSelector:@selector(willAppearIn:) withObject:navController];
}


#pragma mark - log out user method
-(void) logoutUser{
    [ClientManager logout];
    [KeyChainWrapper cleanUpCredentials];
    [ClientManager cancelAllS3Requests];
    [self logoutFBUser];
}

-(void) logoutFBUser{
    for(UIView *view in self.view.subviews){
        if(view.tag == NAME_LOGINOUT_TAG){
            [view removeFromSuperview];
        }
    }
    [FBSession.activeSession closeAndClearTokenInformation];
}

#pragma mark - prepare for segue

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"viewMultiPostsSegue"]){
        [Flurry logEvent:@"Logged_In"];
        NavigationController *nav = segue.destinationViewController;
        nav.delegate = self;
        [nav setUserName:_userName];
    }
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark --
#pragma mark - UI Method
-(void) addLogo{
    UIImage *logoImage = [UIImage imageNamed:@"logo_light.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    if(self.view.bounds.size.height > HEIGHT_TO_DISCRIMINATE){
        [logoImageView setFrame:CGRectMake(29, 122, logoImage.size.width, logoImage.size.height)];
    }else{
        [logoImageView setFrame:CGRectMake(29, 122 - 50, logoImage.size.width, logoImage.size.height)];
    }
    [self.view addSubview:logoImageView];
}

-(UILabel *) addDescriptionsWithString:(NSString *)stringToDisplay andY:(CGFloat)originY withDictionary:(NSDictionary *)dictionary{
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:stringToDisplay attributes:dictionary];
    UILabel *textLabel;
    if(self.view.bounds.size.height > HEIGHT_TO_DISCRIMINATE){
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, WIDTH, 20)];
    }else{
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY-50, WIDTH, 20)];
    }
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel setAttributedText:text];
    [self.view addSubview:textLabel];
    return textLabel;
}


@end
