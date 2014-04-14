//
//  MyPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "MyPostsViewController.h"
#import "KeyChainWrapper.h"

@interface MyPostsViewController ()

@property (strong, nonatomic) NSPredicate *predicate;

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
    UIBarButtonItem *settingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Show" style:UIBarButtonItemStylePlain target:self action:@selector(mySettingButtonPressed:)];
    self.navigationItem.rightBarButtonItem = settingBtn;
    
    self.predicate = [NSPredicate predicateWithFormat:@"isYours = 1"];
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
    
    // these two have to be called together or it only shows refreshing
    // but not actually pulling any data
    [self startRefreshingUp];
    [self.refreshControl beginRefreshing];
    
}

- (void)mySettingButtonPressed:(id)sender{
    NSLog(@"mySettingButtonPressed");
    [self performSegueWithIdentifier:@"viewMySettingSegue" sender:sender];
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
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"User session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, @"my"]
                                                       forKeys:@[@"auth_token", @"type"]];
    
    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded posts from server");
                                           //TODO: make sure this does not run on main thread
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
    //TODO: make sure this can really do the work, not causing race condition
    if (isLoadingMore) return;
    else isLoadingMore = true;
    
    MSDebug(@"Start loading more");
    [super startLoadingMore];
    
    NSNumber *lastOfPreviousPostsIDs = [super fetchLastOfPreviousPostsIDsWithPredicate:self.predicate];
    if (lastOfPreviousPostsIDs == nil) return;
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"User session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[sessionToken, @"my", lastOfPreviousPostsIDs]
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


@end
