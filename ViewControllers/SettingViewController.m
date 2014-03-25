//
//  SettingViewController.m
//  Cells
//
//  Created by Iru on 3/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "SettingViewController.h"
#import "NavigationController.h"

@interface SettingViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation SettingViewController

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
    [_nameLabel setText:[(NavigationController *)self.navigationController getUserName]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma sign out button pressed

- (IBAction)signOutButtonPressed:(id)sender {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Are you sure to sign out?"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Yes",nil];
    [alertView show];
}

#pragma alertView delegate method
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [(NavigationController *)self.navigationController userLoggedOut];
            break;
        default:
            break;
    }
    
}

//#pragma mark - Prepare Segue
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//}



@end
