//
//  BIDAppDelegate.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

//third party library
#import <FacebookSDK/FacebookSDK.h>

#import "AppDelegate.h"

//Client classes
#import "ClientManager.h"
#import "RestKitInitializer.h"
#import "KeyChainWrapper.h"
#import "NavigationController.h"
#import "MultiPostsTabBarController.h"
#import "LoginViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#define NOTIF_BUTTON_TAG 5000

@interface AppDelegate()
@property (strong, nonatomic) UIButton *notifButton;
@property (strong, nonatomic) NSString *notifPostID;
@end

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError *error = nil;
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
//    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Moose.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];/*[managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];*/
    if (! persistentStore) {
        RKLogError(@"Failed adding in-memory persistent store: %@", error);
    }
    [managedObjectStore createManagedObjectContexts];
      
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    // configure the object manager
    // Let's let the URL end with '/' so later in response descriptors or routes we don't need to prefix path patterns with '/'
    // Remeber, evaluation of path patterns against base URL could be surprising.
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    MSDebug(@"BASE URL: %@", BASE_URL);
    
    // DON'T EVER ADD FOLLOWING LINE because last time when I added it, ghost entities pop out everywhere...
    // THIS is kept here for the warning purpose
    //managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    objectManager.managedObjectStore = managedObjectStore;
    // only accepts JSON from the server
    [objectManager setAcceptHeaderWithMIMEType:@"application/json"];
    [RKObjectManager setSharedManager:objectManager];
    
    [RestKitInitializer setupWithObjectManager:objectManager inManagedObjectStore:managedObjectStore];
    
    
    // make sure that the FBLoginView class is loaded before the login view is shown.
    [FBLoginView class];
    
    //note: iOS only allows one crash reporting tool per app; if using another, set to: NO
    [Flurry setCrashReportingEnabled:YES];
    
    // Replace YOUR_API_KEY with the api key in the downloaded package
    [Flurry startSession:FL_APP_KEY];

    // debug/release mode
    MSDebug(@"%@", BUILD_MODE);

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main"
                                                             bundle: nil];
    if(screenHeight < HEIGHT_TO_DISCRIMINATE){
//        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SmallPhoneLaunchVC"];
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        self.window.rootViewController = vc;
    } else{
        UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"LoginVC"];
        self.window.rootViewController = vc;
    }
    
    // Register for PUSH NOTIFICATION
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert |
                                                                           UIRemoteNotificationTypeBadge |
                                                                           UIRemoteNotificationTypeSound)];
 
    
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo) {
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        NSString *alertMsg = @"";
        if( [apsInfo objectForKey:@"alert"] != NULL)
        {
            alertMsg = [apsInfo objectForKey:@"alert"];
        }

//       NSDictionary *userInfo = [localNotif userInfo];
//         NSString *postID = [localNotif objectForKey:@"post_id"];
        NSString * postID = [userInfo objectForKey:@"post_id"];

        MSDebug(@"Recevied remote notification: %@", userInfo);
        MSDebug(@"post_id: %@", postID);
        REMOTE_NOTIF_POST_ID = postID;
        [Flurry logEvent:@"Open_Notification" withParameters:@{@"Status": @"App not running"}];
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //Set Badge number to 0
    ASYNC({
        [ClientManager sendBadgeNumber:0];
    });
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {*/
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
/*
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}*/

#pragma mark -
#pragma mark Push Notification Delegate Methods
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    MSDebug(@"application:didRegisterForRemoteNotificationsWithDeviceToken: %@", deviceToken);
    
    [KeyChainWrapper storeDeviceToken:deviceToken];
    [Flurry logEvent:@"Register_Notification" withParameters:@{@"Status": @"Success"}];
    // Note that ClientManager is called to send device token twice. One is called here. Another one is called when
    // TVMClient receives session token from moose server. The reason is because we don't konw which is received first -
    // device token or session token. Therefore, we call ClientManager to send device token when the app receives either of them
    // and let ClientManager to check if both are ready. If yes, ClientManager sends to device token to moose server.
    [ClientManager sendDeviceToken];
}

- (void)application:(UIApplication *)application
didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [Flurry logEvent:@"Register_Notification" withParameters:@{@"Status": @"Failure"}];
    MSError(@"Error in registering remote notification: %@", error);
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSString * postID = [userInfo objectForKey:@"post_id"];
    MSDebug(@"post_id: %@", postID);
    _notifPostID = postID;

    UIApplicationState state = [application applicationState];
    if (state == UIApplicationStateActive) {
        [Flurry logEvent:@"Receive_Notification_In_Foreground"];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        AudioServicesPlaySystemSound (1003);
        NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
        NSString *alertMsg = @"";
        if( [apsInfo objectForKey:@"alert"] != NULL)
        {
            alertMsg = [apsInfo objectForKey:@"alert"];
        }
        _notifButton = [[UIButton alloc] initWithFrame:CGRectMake(0, -50, WIDTH, 50)];
        [_notifButton setTag:NOTIF_BUTTON_TAG];
        [_notifButton setBackgroundColor:[UIColor colorForYoursWhite]];
        [_notifButton setTitle:alertMsg forState:UIControlStateNormal];
        [_notifButton setTitleColor:[UIColor colorForYoursOrange] forState:UIControlStateNormal];
        _notifButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeueLTStd-Cn" size:16.0];

        [_notifButton addTarget:self action:@selector(notifButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self.window addSubview:_notifButton];
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                              delay:ANIMATION_DELAY
                            options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             _notifButton.frame =
                             CGRectMake(0,
                                        0,
                                        WIDTH,
                                        _notifButton.frame.size.height);
                         }
                         completion:^(BOOL finished){
                             [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(dismissNotifButton) userInfo:nil   repeats:NO];
                         }];
    } else {
        [Flurry logEvent:@"Open_Notification" withParameters:@{@"Status": @"App running in background"}];
        [self displayRemoteNotifPost];
    }
    
    ASYNC({
        [ClientManager sendBadgeNumber:0];
    });
}


-(void) notifButtonPressed{
    [Flurry logEvent:@"Open_Notification" withParameters:@{@"Status": @"App running in foreground"}];
    [self displayRemoteNotifPost];
    [self dismissNotifButton];
}

-(void) dismissNotifButton{
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         _notifButton.frame =
                         CGRectMake(0,
                                    -_notifButton.frame.size.height,
                                    WIDTH,
                                    _notifButton.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [[UIApplication sharedApplication] setStatusBarHidden:NO];
                         for(UIView *view in self.window.subviews){
                             if(view.tag == NOTIF_BUTTON_TAG){
                                 [view removeFromSuperview];
                             }
                         }
                     }];
}

- (void)displayRemoteNotifPost{
    MSDebug(@"Gonna display remote nitification post");
    UIViewController *topController = self.window.rootViewController;
    UIViewController *tabBarController;
    topController = [topController presentedViewController];
    if([topController isKindOfClass:[NavigationController class]]){
        tabBarController = ((NavigationController *)topController).topViewController;
    }
    UIViewController *multiPostsController;
    if([tabBarController isKindOfClass:[MultiPostsTabBarController class]]){
        multiPostsController = ((MultiPostsTabBarController *)tabBarController).selectedViewController;
        if([multiPostsController presentedViewController]){
            [multiPostsController dismissViewControllerAnimated:NO completion:nil];
        }
    }

    [self loadPostAndPerformSegueBy:multiPostsController];
}

- (void)loadPostAndPerformSegueBy:(UIViewController *)presenterViewController
{
    //TODO: find local DB if the app already has it
    
    //If user has not logged in, we are done
    if (![KeyChainWrapper isSessionTokenValid]) {
        return;
    } else if (_notifPostID == nil) {
        return;
    }
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[[KeyChainWrapper getSessionTokenForUser], _notifPostID]
                                                       forKeys:@[@"auth_token", @"post_id"]];
    
    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded the post %@ from server", _notifPostID);
                                           _notifPostID = nil;
                                           MSDebug(@"# of posts loaded for notification: %lu", [[mappingResult array] count]);
                                           Post *post = [[mappingResult array] firstObject]; //There should be only one object loaded
                                           ASYNC({
                                               [ClientManager loadPhotosForPost:post];
                                           });
                                           // tell presenter to perform segue
                                           [presenterViewController performSegueWithIdentifier:@"viewPostSegue" sender:post];
                                       }
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server"
                                                                               block:^{MSError(@"Cannot get the single post!");}]
     ];
}

#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
/*
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}
*/
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
/*
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}*/

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
/*
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Moose.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {*/
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
/*
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}*/

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

#pragma mark - Facebook SDK methods
/**
 Processes the response from interacting with the Facebook login process
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}


@end
