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
    
}

#pragma mark -
#pragma mark Miscellaneous Methods
- (NSArray *)fetchMostPopularPostIDsOfNumber:(NSInteger)number{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Post"];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sort]];
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
