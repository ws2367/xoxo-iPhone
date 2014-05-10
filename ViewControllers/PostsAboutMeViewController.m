//
//  PostsAboutMeViewController.m
//  Cells
//
//  Created by Iru on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//
#import <FacebookSDK/FacebookSDK.h>

#import "PostsAboutMeViewController.h"
#import "ViewPostViewController.h"

#import "KeyChainWrapper.h"

@interface PostsAboutMeViewController ()

@end

@implementation PostsAboutMeViewController

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
    self.type = @"posts_about_me";
    if(self.view.bounds.size.height < HEIGHT_TO_DISCRIMINATE){
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0., CGRectGetHeight(self.tabBarController.tabBar.frame) + HEIGHT - self.view.bounds.size.height, 0);
    } else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    }

    if (![KeyChainWrapper isFBUserIDValid]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if ([result isKindOfClass:[NSDictionary class]]){
                NSDictionary *me = result;
                MSDebug(@"id: %@", [me objectForKey:@"id"]);
                MSDebug(@"name: %@", [me objectForKey:@"name"]);
                
                [KeyChainWrapper storeFBUserID:[me objectForKey:@"id"]];
                
                MSDebug(@"current thread = %@", [NSThread currentThread]);
                MSDebug(@"main thread = %@", [NSThread mainThread]);
                
                self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.fbUserID = %@", [me objectForKey:@"id"]];
                [super setFetchedResultsControllerWithEntityName:@"Post"
                                                       predicate:self.predicate
                                                  sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
                [self.tableView reloadData];
                
                [self startRefreshing];
                [self.refreshControl beginRefreshing];
            } else {
                MSError(@"Cannot retrieve information about me from FB server!");
                return;
            }
        }];
    } else {
        self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.fbUserID = %@", [KeyChainWrapper FBUserID]];
        [super setFetchedResultsControllerWithEntityName:@"Post"
                                               predicate:nil //self.predicate
                                          sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
        
        [self startRefreshing];
        [self.refreshControl beginRefreshing];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


# pragma mark -
#pragma mark BigPostTableViewCell delegate method
-(void)setPostInMyPostsViewController:(id)sender
{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    Post *post = [fetchedResultsController objectAtIndexPath:indexPath];
    [_myPostsViewController setPost:post];
    
}

- (void) CellPerformViewPost:(id)sender{
    //indicate we want to view post from top
    [sender setTag:0];
    [self setPostInMyPostsViewController:sender];
    
    [_myPostsViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)commentPost:(id)sender{
    //indicate we want to comment
    [sender setTag:1];
    [self setPostInMyPostsViewController:sender];
    
    [_myPostsViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)sharePost:(id)sender{
    [Flurry logEvent:@"Share_Post" withParameters:@{@"View":@"PostAboutMe"} timed:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Share this post on your Facebook wall?" message:@"" delegate:self cancelButtonTitle:@"Nevermind" otherButtonTitles:@"Yes", nil];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    alert.tag = indexPath.row;
    [alert show];
    

//    [_myPostsViewController presentViewController:[self createMultiplePeoplePickerViewControllerFrom:sender]
//                       animated:YES completion:nil];
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [_myPostsViewController dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    
    if ([selectedNumbers count] > 0) {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
        [super handleNumbers:selectedNumbers senderIndexPath:indexPath];
    } else {
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}

#pragma mark -
#pragma mark AlertView delegate method
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    //assume only share post use this method
    if(buttonIndex == 1){
        CGSize postSize = CGSizeMake(WIDTH, BIG_POSTS_CELL_HEIGHT);
        UIGraphicsBeginImageContext(postSize);
        CGContextRef resizedContext = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(resizedContext, 0, BIG_POSTS_CELL_HEIGHT*-(alertView.tag));
        [self.tableView.layer renderInContext:resizedContext];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        //        CGSize size = CGSizeMake(WIDTH, BIG_POSTS_CELL_HEIGHT);
        ////        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, self.view.opaque, 0.0);
        //        UIGraphicsBeginImageContext(size);
        //        [self.tableView.layer renderInContext:UIGraphicsGetCurrentContext()];
        //        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        //        UIGraphicsEndImageContext();
        MSDebug(@"shared!");
        //        UIImage *image = [UIImage imageNamed:@"moose.png"];
        [self postImageOnFB:image];
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_YES}];
    } else{
        [Flurry endTimedEvent:@"Share_Post" withParameters:@{FL_IS_FINISHED:FL_NO}];
    }
}
-(void) postImageOnFB:(UIImage *)image{
    BOOL canPresent = [FBDialogs canPresentShareDialogWithPhotos];
    NSLog(@"canPresent: %d", canPresent);
    
    FBShareDialogPhotoParams *params = [[FBShareDialogPhotoParams alloc] init];
    params.photos = @[image];
    
    FBAppCall *appCall = [FBDialogs presentShareDialogWithPhotoParams:params
                                                          clientState:nil
                                                              handler:^(FBAppCall *call, NSDictionary *results, NSError *error) {
                                                                  if (error) {
                                                                      NSLog(@"Error: %@", error.description);
                                                                  } else {
                                                                      NSLog(@"Success!");
                                                                  }
                                                              }];
    if (!appCall) {
        [self performPublishAction:^{
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorAlertUser
            | FBRequestConnectionErrorBehaviorRetry;
            
            [connection addRequest:[FBRequest requestForUploadPhoto:image]
                 completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                     [Utility generateAlertWithMessage:@"posted" error:nil];
                     if (FBSession.activeSession.isOpen) {
                     }
                 }];
            [connection start];
            
        }];
    }
}

- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceFriends
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
    
}



@end
