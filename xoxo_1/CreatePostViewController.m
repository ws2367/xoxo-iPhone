//
//  CreatePostViewController.m
//  Cells
//
//  Created by WYY on 13/10/8.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "CreatePostViewController.h"
#import "BIDViewController.h"
#import "Entity.h"

@interface CreatePostViewController ()
//@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) BIDViewController *bidViewController;

@end

@implementation CreatePostViewController


- (id)initWithBIDViewController:(BIDViewController *)viewController{
    self = [super init];
    if (self) {
        _bidViewController = viewController;// Custom initialization
        _entities = [[NSMutableArray alloc] init];
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
- (IBAction)postButtonPressed:(id)sender {
    [_bidViewController finishCreatingPostBackToHomePage];
}
- (IBAction)backButtonPressed:(id)sender {
    [_bidViewController cancelCreatingPost];
}

- (IBAction)pickImageButtonPressed:(id)sender {
    _picker = [[UIImagePickerController alloc] init];
    _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    _picker.delegate = self;
    _picker.allowsEditing = YES;
    [self presentViewController:_picker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picked didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [[picked presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"Geselecteerd: %@", [info objectForKey:UIImagePickerControllerEditedImage]);
    //photo = [[UIImageView alloc] init];
    [_photo setImage:[info objectForKey:UIImagePickerControllerEditedImage]];
}

//-(void)imagePickController:(UIImagePickerController *)picked didFInishPickingImage

-(void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    int cnt = [_entities count];
    NSLog(@"In CreatPostViewController, count = %d", cnt);

    _entityNames = [NSMutableString string];

    for (Entity *ent in _entities) {
        [_entityNames appendString:ent.name];
        [_entityNames appendString:@", "];
     }
    NSLog((NSString *)_entityNames);
    
    self.entitiesTextField.text = (NSString *)_entityNames;
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
