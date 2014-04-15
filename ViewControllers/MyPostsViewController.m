//
//  MyPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>

#import "MyPostsViewController.h"
#import "KeyChainWrapper.h"

#import "UIColor+MSColor.h"

@interface MyPostsViewController ()

@property (strong, nonatomic) NSPredicate *predicate;
@property (strong, nonatomic) NSString *type;

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
    
    [self buttonFactoryWithTitle:@"Posts about me" selector:@selector(postsAboutMeButtonClicked:) frame:
     [self buttonFactoryWithTitle:@"My Posts" selector:@selector(myPostsButtonClicked:) frame:CGRectMake(20, 50, 150, 30)]];
    
    self.type = @"my_posts";
    self.predicate = [NSPredicate predicateWithFormat:@"isYours = 1"];
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
    
    // these two have to be called together or it only shows refreshing
    // but not actually pulling any data
    [self startRefreshingUp];
    [self.refreshControl beginRefreshing];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(CGRect)buttonFactoryWithTitle:(NSString *)title selector:(SEL)selector frame:(CGRect)frame{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorForYoursWhite] forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor colorForYoursOrange]];
    button.frame = frame;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    frame.origin.y += frame.size.height + 5;
    return frame;
}

#pragma mark -
#pragma mark Button methods
-(void)myPostsButtonClicked:(id)sender{
    self.type = @"posts_about_me";
    self.predicate = [NSPredicate predicateWithFormat:@"isYours = 1"];
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
    
    [self startRefreshingUp];
    [self.refreshControl beginRefreshing];
    [self.tableView reloadData];
}

- (void)postsAboutMeButtonClicked:(id)sender{
    if (![KeyChainWrapper isFBUserIDValid]) {
        [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if ([result isKindOfClass:[NSDictionary class]]){
                NSDictionary *me = result;
                MSDebug(@"id: %@", [me objectForKey:@"id"]);
                MSDebug(@"name: %@", [me objectForKey:@"name"]);
                
                [KeyChainWrapper storeFBUserID:[me objectForKey:@"id"]];
                
                self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.fbUserID = %@", [me objectForKey:@"id"]];
                [super setFetchedResultsControllerWithEntityName:@"Post"
                                                       predicate:self.predicate
                                                  sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
                
                [self.tableView reloadData];
                
            } else {
                MSError(@"Cannot retrieve information about me from FB server!");
                return;
            }
        }];
    } else {
        self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.fbUserID = %@", [KeyChainWrapper FBUserID]];
        [super setFetchedResultsControllerWithEntityName:@"Post"
                                               predicate:self.predicate
                                          sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
        
        [self.tableView reloadData];

    }
    
}

- (void)mySettingButtonPressed:(id)sender{
    MSDebug(@"mySettingButtonPressed");
    [self performSegueWithIdentifier:@"viewMySettingSegue" sender:sender];
}



#pragma mark -
#pragma mark Refreshing Methods
- (NSMutableDictionary *)paramsGenerator{
    NSString *sessionToken = [KeyChainWrapper getSessionTokenForUser];
    
    return [NSMutableDictionary dictionaryWithObjects:@[sessionToken, _type]
                                       forKeys:@[@"auth_token", @"type"]];
    
}

- (void)startRefreshingUp{
    [super startRefreshingUp];
    
    // check if seesion token is valid
    if (![KeyChainWrapper isSessionTokenValid]) {
        NSLog(@"User session token is not valid. Stop refreshing up");
        [self.refreshControl endRefreshing];
        return;
    }
    
    NSDictionary *params = [self paramsGenerator];
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
    
    NSMutableDictionary *params = [self paramsGenerator];
   [params setObject:lastOfPreviousPostsIDs forKey:@"last_of_previous_post_ids"];
    
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
