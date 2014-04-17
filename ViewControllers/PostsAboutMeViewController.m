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
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);

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
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    MultiplePeoplePickerViewController *picker = [[MultiplePeoplePickerViewController alloc] init];
    picker.delegate = self;
    [picker setSenderIndexPath:indexPath];
    [_myPostsViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [_myPostsViewController dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    
    if ([selectedNumbers count] > 0) {
        [super handleNumbers:selectedNumbers senderIndexPath:indexPath];
    }
}

@end
