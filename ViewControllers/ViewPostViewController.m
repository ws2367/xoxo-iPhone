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
    [self setPic:@"pic1"];
    
    // TODO: sort it by the time of creation, not by content
    _comments = [_post.comments sortedArrayUsingDescriptors:
                         @[[NSSortDescriptor sortDescriptorWithKey:@"content" ascending:YES]]
                         ];

}
- (IBAction)backButtonPressed:(id)sender {
    [_viewMultiPostsViewController cancelViewingPost];
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
#pragma mark Table Data Source Methods
- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_post.comments count];

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




@end
