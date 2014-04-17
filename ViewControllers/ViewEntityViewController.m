//
//  ViewEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/20.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "MultiplePeoplePickerViewController.h"
#import "ViewEntityViewController.h"
#import "ViewEntityPostsViewController.h"
#import "ViewPostViewController.h"
#import "NavigationController.h"
#import "CreatePostViewController.h"

#import "BigPostTableViewCell.h"

#import "KeyChainWrapper.h"

#import "Post+MSClient.h"
#import "Entity.h"

#import "UIColor+MSColor.h"

@interface ViewEntityViewController ()


// entity attributes
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (strong, nonatomic) NSString *name;
@property (weak, nonatomic) IBOutlet UILabel *institutionLabel;
@property (strong, nonatomic) NSString *institution;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (strong, nonatomic) NSString *location;

@end

@implementation ViewEntityViewController


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
    
    // set up entity
    [self setNameAndInstitutionAndLocation];
    [self addNavigationBar];
    [self addCreatePostButton];
    
    //set up child view controller
    // embedded view controller is a child view controller
    ViewEntityPostsViewController *childViewController = [self.childViewControllers firstObject];
    // set up entity for child view controller first, then fire off it
    childViewController.entity = self.entity;
    [childViewController fireOff];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Add bar and buttons
-(void) addNavigationBar{
    //add top controller bar
    UINavigationBar *topNavigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, WIDTH, VIEW_POST_NAVIGATION_BAR_HEIGHT)];
    [topNavigationBar setBarTintColor:[UIColor colorForYoursOrange]];
    [topNavigationBar setTranslucent:NO];
    [topNavigationBar setTintColor:[UIColor whiteColor]];
    [topNavigationBar setTitleTextAttributes:[Utility getMultiPostsContentFontDictionary]];
    [self.view addSubview:topNavigationBar];
    
    UIBarButtonItem *exitButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon-cancel.png"] style:UIBarButtonItemStylePlain target:self action:@selector(exitButtonPressed:)];
    [exitButton setTintColor:[UIColor whiteColor]];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu-popular.png"] style:UIBarButtonItemStylePlain target:self action:@selector(homeButtonPressed:)];
    
    [exitButton setTintColor:[UIColor whiteColor]];
    
    UINavigationItem *topNavigationItem = [[UINavigationItem alloc] initWithTitle:[_entity name]];
    
    topNavigationItem.rightBarButtonItem = exitButton;
    topNavigationItem.leftBarButtonItem = homeButton;
    topNavigationBar.items = [NSArray arrayWithObjects: topNavigationItem,nil];
}

-(void)addCreatePostButton{
    UIImage *buttonImage = [UIImage imageNamed:@"menu-addpost.png"];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(100, 100, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(createPostButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [button setCenter:CGPointMake(WIDTH/2, HEIGHT - (buttonImage.size.height/2))];
    [self.view addSubview:button];
}

#pragma mark -
#pragma mark Navigation Bar Button Methods
- (void)exitButtonPressed:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)homeButtonPressed:(id)sender{
    UIViewController *thisViewController = self;
    while (![thisViewController isKindOfClass:[NavigationController class]]) {
        thisViewController = [thisViewController presentingViewController];
    }
    [thisViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)createPostButtonPressed:(id)sender{
    [self performSegueWithIdentifier:@"createPostSegue" sender:sender];
}


# pragma mark -
#pragma mark Prepare Segue
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if ([segue.identifier isEqualToString:@"viewPostSegue"]){
        ViewPostViewController *nextController = segue.destinationViewController;
        
        if (!_post) {
            MSError(@"No post is set when performing viewPostSegue");
        }
        [nextController setPost:_post];
        if ([sender tag] == 0) {
            [nextController setStartEditingComment:NO];
        }else{
            [nextController setStartEditingComment:YES];
        }
    } else if ([segue.identifier isEqualToString:@"createPostSegue"]){
        CreatePostViewController *nextController = segue.destinationViewController;
        [nextController addEntity:_entity];
    }
}


#pragma mark -
#pragma mark Miscellaneous Methods
- (void) setNameAndInstitutionAndLocation{
    if (_entity) {
        _name = [[NSString alloc] initWithString:_entity.name];
        _nameLabel.text = _name;
        MSDebug(@"Entity name: %@", _name);
        if (_entity.institution) {
            _institution = [[NSString alloc] initWithString:_entity.institution];
            _institutionLabel.text = _institution;
            MSDebug(@"Entity institution: %@", _institution);
        }
        if (_entity.location) {
            _location = [[NSString alloc] initWithString:_entity.location];
            _locationLabel.text = _location;
            MSDebug(@"Entity location: %@", _location);
        }
    }
}

@end
