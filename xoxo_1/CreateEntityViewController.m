//
//  CreateEntityViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreateEntityViewController.h"
#import "BIDViewController.h"

@interface CreateEntityViewController ()
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) BIDViewController *bidViewController;

@end

@implementation CreateEntityViewController
- (IBAction)notHereButtonPressed:(id)sender {
    [_bidViewController finishCreatingEntityStartCreatingPost];
}

- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
    }
    return self;
}

- (IBAction)cancelButtonPressed:(id)sender {
    //[(BIDViewController *)[self presentingViewController] cancelButton];
    //[(BIDViewController *)self.presentingViewController cancelButton];
    [_bidViewController cancelCreatingEntity];
}

- (IBAction)createNewEntity:(id)sender {
}
- (IBAction)nameTextFieldPressed:(id)sender {
}


//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

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
#pragma mark TextField Delegate

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}

@end
