//
//  PopularPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "PopularPostsViewController.h"

#import "KeyChainWrapper.h"

#import "Post.h"

@interface PopularPostsViewController ()

@end

@implementation PopularPostsViewController

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
    
    [super setFetchedResultsControllerWithEntityName:@"Post" predicate:nil
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];

    
    // these two have to be called together or it only shows refreshing but not actually pulling any data
    [self startRefreshingUp];
    [self.refreshControl beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Refreshing Methods

- (void)startRefreshingUp{
    [super startRefreshingUp];

    // fetch ten most popular posts ids
//    NSArray *localPostIDs = [super fetchMostPopularPostIDsOfNumber:10 predicate:nil];
//    NSArray *localEntityIDs = [super fetchEntityIDsOfNumber:40];
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"At PopularPostsViewController: user session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
//    MSDebug(@"post IDs to be pushed to server: %@", localPostIDs);
//    MSDebug(@"entity IDs to be pushed to server: %@", localEntityIDs);
    
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[localPostIDs, localEntityIDs, sessionToken, @"popular"]
//                                                       forKeys:@[@"Post", @"Entity", @"auth_token", @"type"]];

    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, @"popular"]
                                                       forKeys:@[@"auth_token", @"type"]];

    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded posts from server");
                                           NSArray *posts = [mappingResult array];
                                           for (Post *post in posts) {
                                               [super loadPhotosForPost:post];
                                           }
                                           [self.refreshControl endRefreshing];
                                       }
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server"
                                                                               block:^{[self.refreshControl endRefreshing];}]
     ];
}



- (void)startLoadingMore{
    if (isLoadingMore) return;
    else isLoadingMore = true;
    
    MSDebug(@"Start loading more");
    [super startLoadingMore];
    
    NSNumber *lastOfPreviousPostsIDs = [super fetchLastOfPreviousPostsIDsWithPredicate:nil];
    if (lastOfPreviousPostsIDs == nil) return;
    
    //NSArray *localEntityIDs = [super fetchEntityIDsOfNumber:40];
    //MSDebug(@"entity IDs to be pushed to server: %@", localEntityIDs);
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"At PopularPostsViewController: user session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
//    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[localEntityIDs, sessionToken, @"popular", lastOfPreviousPostsIDs]
//                                                       forKeys:@[@"Entity", @"auth_token", @"type", @"last_of_previous_post_ids"]];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, @"popular", lastOfPreviousPostsIDs]
                                                       forKeys:@[@"auth_token", @"type", @"last_of_previous_post_ids"]];
    
    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded more posts from server");
                                           isLoadingMore = false;
                                           NSArray *posts = [mappingResult array];
                                           for (Post *post in posts) {
                                               [super loadPhotosForPost:post];
                                           }
                                       }
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't connect to the server"
                                                                               block:^{isLoadingMore = false;}]
     ];

    

}

#pragma mark -
#pragma mark Miscellaneous Methods


@end
