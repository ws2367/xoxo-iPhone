//
//  SmallPhoneLaunchViewController.m
//  Cells
//
//  Created by Iru on 4/23/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "SmallPhoneLaunchViewController.h"

@interface SmallPhoneLaunchViewController ()

@end

@implementation SmallPhoneLaunchViewController

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
    [self.view setBackgroundColor:[UIColor colorForYoursOrange]];
    [self addLogo];
    [self addDescriptionsWithString:@"Sorry we only support iPhone 5 or up..." andY:300 withDictionary:[Utility getLoginViewTitleDescriptionFontDictionary]];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark - UI Method
-(void) addLogo{
    UIImage *logoImage = [UIImage imageNamed:@"logo_white.png"];
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:logoImage];
    [logoImageView setFrame:CGRectMake(24, 113, logoImage.size.width, logoImage.size.height)];
    [self.view addSubview:logoImageView];
}

-(UILabel *) addDescriptionsWithString:(NSString *)stringToDisplay andY:(CGFloat)originY withDictionary:(NSDictionary *)dictionary{
    NSAttributedString *text = [[NSAttributedString alloc] initWithString:stringToDisplay attributes:dictionary];
    UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, originY, WIDTH, 20)];
    textLabel.textAlignment = NSTextAlignmentCenter;
    [textLabel setAttributedText:text];
    [self.view addSubview:textLabel];
    return textLabel;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
