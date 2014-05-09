//
//  FavoritesPostsViewController.m
//  Cells
//
//  Created by Iru on 3/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "FavoritesPostsViewController.h"
#import "KeyChainWrapper.h"

@interface FavoritesPostsViewController ()

@end

@implementation FavoritesPostsViewController

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
    
    self.type = @"following";
    self.predicate = [NSPredicate predicateWithFormat:@"following = 1 AND index != 0"];
    [super setFetchedResultsControllerWithEntityName:@"Post"
                                           predicate:self.predicate
                                      sortDescriptor:[NSSortDescriptor sortDescriptorWithKey:@"index" ascending:YES]];
    
    // these two have to be called together or it only shows refreshing but not actually pulling any data
    [self startRefreshing];
    [self.refreshControl beginRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
