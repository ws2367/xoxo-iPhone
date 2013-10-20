//
//  ViewPostViewController.m
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewPostViewController.h"
#import "BIDViewController.h"

@interface ViewPostViewController ()


@property (weak, nonatomic)IBOutlet UIImageView *postImage;
@property (weak, nonatomic) BIDViewController *bidViewController;

@end

@implementation ViewPostViewController


- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
    }
    return self;
}


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
    // Do any additional setup after loading the view from its nib.
}
- (IBAction)backButtonPressed:(id)sender {
    [_bidViewController cancelViewingPost];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setPic:(NSString *)c
{
    if (![c isEqualToString:_pic]) {
        _pic = [c copy];
        _postImage.image = [UIImage imageNamed:_pic];
    }
}


@end
