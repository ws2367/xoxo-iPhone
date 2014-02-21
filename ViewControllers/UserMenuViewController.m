//
//  UserMenuViewController.m
//  Cells
//
//  Created by WYY on 2013/11/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "UserMenuViewController.h"
#import "ViewMultiPostsViewController.h"


@interface UserMenuViewController ()
@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIView *blackMaskOnTopOfView;

@end

#define SEARCHBAR_Y 30
#define SEARCHBAR_HEIGHT 40


@implementation UserMenuViewController


- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsViewController = viewController;// Custom initialization
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(WIDTH/2, SEARCHBAR_Y, WIDTH/2, SEARCHBAR_HEIGHT)];
        [self.view addSubview:_searchBar.viewForBaselineLayout];
        [_searchBar setDelegate:self];
        //[_searchBar setShowsSearchResultsButton:YES];
        
        
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark UISearchBar Delegate Methods
//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
//    _blackMaskOnTopOfView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, HEIGHT)];
//    //UITapGestureRecognizer *tapBIDView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
//    
//    //[_blackMaskOnTopOfView addGestureRecognizer:tapBIDView];
//    
//    [_blackMaskOnTopOfView setOpaque:NO];
//    [_blackMaskOnTopOfView setAlpha:0];
//    [_blackMaskOnTopOfView setBackgroundColor:[UIColor blackColor]];
//    [self.view addSubview:_blackMaskOnTopOfView];
//    
//    [UIView animateWithDuration:ANIMATION_DURATION
//                          delay:ANIMATION_DELAY
//                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
//                     animations:^{
//                         [_blackMaskOnTopOfView setAlpha:0.6];
//                         
//                     }
//                     completion:^(BOOL finished){
//                     }];
//}

- (void)searchBarTextDidBeginEditing:(UISearchBar*)searchBar
{
    [self searchBarTapped];
}


#pragma mark -
#pragma mark Rearrange View Methods

- (void)searchBarTapped{
    NSLog(@"gotit!");
    CGFloat blackMaskY = SEARCHBAR_HEIGHT + SEARCHBAR_Y;
    _blackMaskOnTopOfView = [[UIView alloc] initWithFrame:CGRectMake(0, blackMaskY, WIDTH, HEIGHT - blackMaskY)];
    UITapGestureRecognizer *tapBIDView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelSearch)];
    
    [_blackMaskOnTopOfView addGestureRecognizer:tapBIDView];
    
    [_blackMaskOnTopOfView setOpaque:NO];
    [_blackMaskOnTopOfView setAlpha:0];
    [_blackMaskOnTopOfView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:_blackMaskOnTopOfView];
    [_viewMultiPostsViewController beginSearchTakeOverWindow];
    
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         [_blackMaskOnTopOfView setAlpha:0.6];
                         [_searchBar setFrame:CGRectMake(0, SEARCHBAR_Y, WIDTH, SEARCHBAR_HEIGHT)];
                         
                     }
                     completion:^(BOOL finished){
                     }];
}

- (void)cancelSearch{
    [_viewMultiPostsViewController endSearchTakeOverWindow];
    [_searchBar endEditing:YES];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         [_blackMaskOnTopOfView setAlpha:0];
                         [_searchBar setFrame:CGRectMake(WIDTH/2, SEARCHBAR_Y, WIDTH/2, SEARCHBAR_HEIGHT)];
                         
                     }
                     completion:^(BOOL finished){
                         [_blackMaskOnTopOfView removeFromSuperview];
                     }];
}


@end
