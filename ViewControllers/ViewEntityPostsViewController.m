//
//  ViewEntityPostsViewController.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 4/17/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewEntityPostsViewController.h"

@interface ViewEntityPostsViewController ()

@end

@implementation ViewEntityPostsViewController

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

- (void)fireOff
{
    MSDebug(@"Entity in viewEntityPosts: %@", self.entity);
    
    // set up fetched results controller
    self.type = @"popular";
    self.predicate = [NSPredicate predicateWithFormat:@"ANY entities.remoteID = %@", _entity.remoteID];
    
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"popularity" ascending:NO]];
    
    [self startRefreshing];
    [self.refreshControl beginRefreshing];

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
    [_viewEntityViewController setPost:post];
}

- (void) CellPerformViewPost:(id)sender{
    //indicate we want to view post from top
    [sender setTag:0];
    [self setPostInMyPostsViewController:sender];
    
    [_viewEntityViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)commentPost:(id)sender{
    //indicate we want to comment
    [sender setTag:1];
    [self setPostInMyPostsViewController:sender];
    
    [_viewEntityViewController performSegueWithIdentifier:@"viewPostSegue" sender:sender];
}

-(void)sharePost:(id)sender{
    CGPoint buttonPosition = [sender convertPoint:CGPointZero toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:buttonPosition];
    
    MultiplePeoplePickerViewController *picker = [[MultiplePeoplePickerViewController alloc] init];
    picker.delegate = self;
    [picker setSenderIndexPath:indexPath];
    [_viewEntityViewController presentViewController:picker animated:YES completion:nil];
}

#pragma mark -
#pragma mark Multile People Picker Delegate Methods
- (void) donePickingMutiplePeople:(NSSet *)selectedNumbers senderIndexPath:(NSIndexPath *)indexPath
{
    [_viewEntityViewController dismissViewControllerAnimated:YES completion:nil];
    MSDebug(@"Selected numbers %@", selectedNumbers);
    
    if ([selectedNumbers count] > 0) {
        [super handleNumbers:selectedNumbers senderIndexPath:indexPath];
    }
}
@end
