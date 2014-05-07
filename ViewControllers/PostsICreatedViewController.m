//
//  PostsICreatedViewController.m
//  Cells
//
//  Created by Iru on 4/15/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "PostsICreatedViewController.h"
#import "ViewPostViewController.h"

#import "KeyChainWrapper.h"

@interface PostsICreatedViewController ()

@end

@implementation PostsICreatedViewController

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
    if(self.view.bounds.size.height < HEIGHT_TO_DISCRIMINATE){
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0., CGRectGetHeight(self.tabBarController.tabBar.frame) + HEIGHT - self.view.bounds.size.height, 0);
    } else{
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0., CGRectGetHeight(self.tabBarController.tabBar.frame), 0);
    }
	// Do any additional setup after loading the view.
    
    self.type = @"my_posts";
    self.predicate = [NSPredicate predicateWithFormat:@"isYours = 1"];
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
    
    // these two have to be called together or it only shows refreshing
    // but not actually pulling any data
    [self startRefreshing];
    [self.refreshControl beginRefreshing];
}

-(void) viewDidAppear:(BOOL)animated{
    if(_postToScrollTo){
        [self scrollToPost:_postToScrollTo];
        _postToScrollTo = NULL;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark -
#pragma mark BigPostTableViewCell delegate method
//TODO: Set a presenter which could be self or its parent controller. Then we don't need to rewrite all these methods!!
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
    [Flurry logEvent:@"Share_Post" withParameters:@{@"View":@"PostsICreated"} timed:YES];
    [_myPostsViewController presentViewController:[self createMultiplePeoplePickerViewControllerFrom:sender]
                                         animated:YES completion:nil];
}

-(void)reportPost:(id)sender{
    [Flurry logEvent:@"Report_Post" withParameters:@{@"View":@"PostsICreated"} timed:YES];
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Are you sure to report this post?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:@"Report It"
                                              otherButtonTitles:nil];
    
    [sheet setTag:indexPath.row];
    [sheet showInView:_myPostsViewController.view];
//    [sheet show];
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
#pragma mark Multile People Picker Delegate Methods
-(void) scrollToPost:(Post *)post{
    
    MSDebug(@"im called!!");
    NSIndexPath *indexPath = [fetchedResultsController indexPathForObject:post];
    MSDebug(@"my index %@", indexPath);
    CGFloat offset = indexPath.row*BIG_POSTS_CELL_HEIGHT;
    [self.tableView setContentOffset:CGPointMake(0, offset) animated:NO];
}

@end
