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
    
    //set up fetched results controller
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Post"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"popularity" ascending:NO];
    request.sortDescriptors = @[sort];
    
    fetchedResultsController =
    [[NSFetchedResultsController alloc]
     initWithFetchRequest:request
     managedObjectContext:[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext
     sectionNameKeyPath:nil
     cacheName:nil];
    
    fetchedResultsController.delegate = self;
    
    // Let's perform one fetch here
    NSError *fetchingErr = nil;
    if ([fetchedResultsController performFetch:&fetchingErr]){
        NSLog(@"Successfully fetched.");
    } else {
        NSLog(@"Failed to fetch");
    }
    
    // set up and fire off refresh control
    self.refreshControl = [UIRefreshControl new];
    [self.refreshControl addTarget:self action:@selector(startRefreshingUp) forControlEvents:UIControlEventValueChanged];
    
    // these two have to be called together or it only shows refreshing but not actually pulling any data
    [self startRefreshingUp];
    [self.refreshControl beginRefreshing];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startRefreshingUp{
    [super startRefreshingUp];

    // fetch ten most popular posts ids
    NSArray *localPostIDs = [self fetchMostPopularPostIDsOfNumber:10];
    NSArray *localEntityIDs = [super fetchEntityIDsOfNumber:40];
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"At PopularPostsViewController: user session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    MSDebug(@"post IDs to be pushed to server: %@", localPostIDs);
    MSDebug(@"entity IDs to be pushed to server: %@", localEntityIDs);
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[localPostIDs, localEntityIDs, sessionToken, @"popular"]
                                                       forKeys:@[@"Post", @"Entity", @"auth_token", @"type"]];
    
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


- (void)startRefreshingDown{
    [super startRefreshingDown];
    
    NSNumber *lastOfPreviousPostsIDs = [self fetchLastOfPreviousPostsIDs];
    NSArray *localEntityIDs = [super fetchEntityIDsOfNumber:40];
    MSDebug(@"entity IDs to be pushed to server: %@", localEntityIDs);
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"At PopularPostsViewController: user session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjects:@[localEntityIDs, sessionToken, @"popular", lastOfPreviousPostsIDs]
                                                       forKeys:@[@"Entity", @"auth_token", @"type", @"last_of_previous_posts_id"]];
    
    [[RKObjectManager sharedManager] getObject:[Post alloc]
                                          path:nil
                                    parameters:params
                                       success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           MSDebug(@"Successfully loadded more posts from server");
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

#pragma mark -
#pragma mark Miscellaneous Methods
- (NSNumber *)fetchLastOfPreviousPostsIDs{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByPopularity = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO];
    NSSortDescriptor *sortByUpdateDate = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    NSSortDescriptor *sortByRemoteID = [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByPopularity, sortByUpdateDate, sortByRemoteID,nil]];
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    
}

- (NSArray *)fetchMostPopularPostIDsOfNumber:(NSInteger)number{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sortByPopularity = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO];
    NSSortDescriptor *sortByUpdateDate = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    NSSortDescriptor *sortByRemoteID = [NSSortDescriptor sortDescriptorWithKey:@"remoteID" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortByPopularity, sortByUpdateDate, sortByRemoteID,nil]];
    [request setFetchLimit:number];
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSMutableArray *ids = [[NSMutableArray alloc] init];
    if ([match count] > number) {
        NSLog(@"Fetched more than fetch limit!");
    } else if ([match count] == 0){
        // an empty array
        // do nothing
    } else {
        [match enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [ids addObject:[(Post *)obj remoteID]];
        }];
    }
    return ids;
}


@end
