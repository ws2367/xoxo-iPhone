//
//  ViewPostViewController.m
//  Cells
//
//  Created by WYY on 13/10/18.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "ViewPostViewController.h"
#import "ViewMultiPostsViewController.h"
#import "CommentTableViewCell.h"
#import "Post.h"
#import "Comment.h"

@interface ViewPostViewController ()

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (strong, nonatomic) NSString *content;

@property (weak, nonatomic) IBOutlet UITextField *commentTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic)IBOutlet UIImageView *postImage;

@property (weak, nonatomic) ViewMultiPostsViewController *viewMultiPostsViewController;

@property (strong, nonatomic) NSArray *comments; //store comment pointers

//TODO: kill it after having real pictures
@property (strong, nonatomic) NSString *pic;

@end

#define ROW_HEIGHT 46

@implementation ViewPostViewController


- (id)initWithViewMultiPostsViewController:(ViewMultiPostsViewController *)viewController{
    self = [super init];
    if (self) {
        _viewMultiPostsViewController = viewController;// Custom initialization
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

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillShow:)
     name:UIKeyboardWillShowNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleKeyboardWillHide:)
     name:UIKeyboardWillHideNotification
     object:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up table view
    _tableView.rowHeight = ROW_HEIGHT;
    UINib *nib = [UINib nibWithNibName:@"CommentTableViewCell"
                                bundle:nil];
    [_tableView registerNib:nib
       forCellReuseIdentifier:CellTableIdentifier];
    
    // set the content
    _content = [[NSString alloc] initWithString:_post.content];
    _contentTextView.text = _content;
    
    // Note: I have tested that post and its related entities are visible here
    // Also, I used Core Data Editor to test that comments do show up
    
    //TODO: kill it after having real pictures
    //TODO: we might want to use @"photos.@count" in the predicate, check Key Value Coding and Advanced Query
    [self setPic:@"pic1"];
    
    // TODO: sort it by the time of creation, not by content
    _comments = [_post.comments sortedArrayUsingDescriptors:
                         @[[NSSortDescriptor sortDescriptorWithKey:@"content" ascending:YES]]
                         ];
    
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

#pragma mark -
#pragma mark Keyboard Notifification Methods
- (void) handleKeyboardWillShow:(NSNotification *)paramNotification{
    
    // get the frame of the keyboard
    NSValue *keyboardRectAsObject = [[paramNotification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    // place it in a CGRect
    CGRect keyboardRect = CGRectZero;
    
    // I know this all looks winding and turning, keyboardRecAsObject is set type of NSValue
    // because collections like NSDictionary which is returned by [paramNotification userInfo]
    // can only store objects, not CGRect which is a C struct
    [keyboardRectAsObject getValue:&keyboardRect];
    
    // set the whole view to be right above keyboard
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame =
                         CGRectMake(self.view.frame.origin.x,
                                    keyboardRect.origin.y - self.view.frame.size.height,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];
}

//Oooooops. While the keyboard is moving, the super view leaks itself on the screen
//TODO: make a background view to prevent it
- (void) handleKeyboardWillHide:(NSNotification *)paramNotification{
    // let's move the view back to full screen position
    [UIView animateWithDuration:ANIMATION_KEYBOARD_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         self.view.frame =
                         CGRectMake(0,
                                    0,
                                    self.view.frame.size.width,
                                    self.view.frame.size.height);
                     }
                     completion:^(BOOL finished){
                     }];

}

#pragma mark -
#pragma mark Button Methods
- (IBAction)backButtonPressed:(id)sender {
    [_viewMultiPostsViewController cancelViewingPost];
}

- (IBAction)postComment:(id)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    Comment *comment = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:appDelegate.managedObjectContext];

    // This is better than [comment setValue:..... forKey:@"content"]
    // because literal string is not type-checked, but @properties are.
    comment.content = _commentTextField.text;
    
    [_post addCommentsObject:comment];
    
    NSError *SavingError = nil;
    if (![appDelegate.managedObjectContext save:&SavingError]){
        NSLog(@"Failed to save in commenting");
        NSLog(@"%@", [SavingError localizedFailureReason]);
        NSLog(@"%@", [SavingError localizedDescription]);
        NSLog(@"%@", [SavingError localizedRecoveryOptions]);
        NSLog(@"%@", [SavingError localizedRecoverySuggestion]);
        NSLog(@"%@", [SavingError userInfo]);
    } else {
        NSLog(@"Saved Successfully in commenting");
        _comments = [_post.comments sortedArrayUsingDescriptors:
                     @[[NSSortDescriptor sortDescriptorWithKey:@"content" ascending:YES]]
                     ];
        
        // TODO: we might want to add observer to observe the context change and thereafter
        // reload table view, using a method to listen to
        [_tableView reloadData];
    }
}

#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_comments count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellTableIdentifier];
    
    Comment *comment = _comments[indexPath.row];
    
    cell.content = comment.content;
    cell.likeNum = [comment.likersNum integerValue];
    cell.hateNum = [comment.hatersNum integerValue];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleDefault];

    return cell;
}


#pragma mark -
#pragma mark TextField Delegate methods

-(BOOL) textFieldShouldReturn:(UITextField*) textField {
    [textField resignFirstResponder];
    return YES;
}


- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    if ([Utility compareUIColorBetween:[textField textColor] and:[UIColor lightGrayColor]]) {
        [textField setTextColor:[UIColor blackColor]];
        [textField setText:@""];
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField
{
    if ([[textField text] isEqualToString:@""]) {
        [textField setTextColor:[UIColor lightGrayColor]];
        [textField setText:@"Write a comment..."];
    }
}




@end
