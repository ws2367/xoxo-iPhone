//
//  BigPostTableViewCell.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BigPostTableViewCell.h"
#import <QuartzCore/QuartzCore.h> //for gradient color

@interface BigPostTableViewCell()

@property (strong,nonatomic)  UIImageView *mooseView;

@property (strong,nonatomic)  UIView *blackMask;
@property (nonatomic) bool gradientFlag;

@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UIButton *entityButton;

@property (strong, nonatomic) IBOutlet UIImageView *postImageView;

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (copy, nonatomic) NSString *dateToShow;

/*
@property (strong, nonatomic) IBOutlet UIButton *likeButton;
@property (strong, nonatomic) IBOutlet UIButton *hateButton;
@property (strong, nonatomic) IBOutlet UILabel *likeValue;
@property (strong, nonatomic) IBOutlet UILabel *hateValue;
 */
// TODO: what it this lowerMask for??
//@property (weak, nonatomic) IBOutlet UIView *lowerMask;


@end

@implementation BigPostTableViewCell{
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //[_lowerMask setAlpha:0.8];
        //_lowerMask.opaque = FALSE;
        //_gradientFlag = FALSE;
        //[self createGradient];
    }
    return self;
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// set content of posts as well as other attributes which are hard-coded
// This is a setter that is wired with the variable content by objective-C automatically
- (void)setContent:(NSString *)n
{
    if (![n isEqualToString:_content]) {
        //TODO: check if this copying actually works as we want
        _content = [n copy];
        //NSRange stringRange = {0,65};
        //if(_content.length > 65){
        //    _content = [_content substringWithRange:stringRange];
        //    _content = [_content stringByAppendingFormat:@"..."];
        //}
        _contentTextView.text = _content;
    }
    
    /*
     _likeNum = 4;
    _hateNum = 3;
    _likeValue.text = [NSString stringWithFormat:@"%d", (int)_likeNum];
    _hateValue.text = [NSString stringWithFormat:@"%d", (int)_hateNum];
    
    _liked = false;
    _hated = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
     */

}

// This is a setter that is wired with the variable entities by objective-C automatically
// TODO: copy objects to _entities then show _entities on the view instead of outter pointers
// Like what we do in setContent
-(void) setEntities:(NSArray *)entities{
    
    if ([entities count] > 0) {
        // TOOD: change it to show multiple names
        [_entityButton setTitle:[entities objectAtIndex:0][@"name"] forState:UIControlStateNormal];

        /*for(NSDictionary *item in JSONArr) {
        [self.posts addObject:item];
         }*/
        //NSDictionary
        //NSArray *keys = [entities allValues];
        //  NSLog(@"%@",keys);
        //NSArray *eachEntity = [entities allValues];
        //NSLog(@"%@", [eachEntity objectAtIndex:0]);
    }
}


- (void)setImage:(UIImage *)image
{
    _postImageView.image = image;
    [self createGradient];
}


-(void) setDateToShow:(NSString *)dateToShow{
    _dateToShow = [dateToShow copy];
    _dateLabel.text = _dateToShow;
}



#pragma mark -
#pragma mark Button Methods
// TODO: we gonna use exclamation mark instead of like or hate
/*
- (IBAction)likeButtonPressed: (id)sender {
    if([self isLiked]){
        _liked = false;
        _likeNum--;
        _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
        [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    }else{
        _liked = true;
        _likeNum++;
        _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
        [_likeButton setImage:[UIImage imageNamed:@"likeon"] forState:UIControlStateNormal];
    }
}

- (IBAction)hateButtonPressed: (id)sender {
    if([self isHated]){
        _hated = false;
        _hateNum--;
        _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
        [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];
    }else{
        _hated = true;
        _hateNum++;
        _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
        [_hateButton setImage:[UIImage imageNamed:@"hateon"] forState:UIControlStateNormal];
    }
}
 */


#pragma mark -
#pragma mark Swipe Methods
- (void) swipeLeft{
    
}
- (void) swipeRight{
    _mooseView = [[UIImageView alloc] init];
    _mooseView.frame = CGRectMake(-WIDTH + 135, 70, 50, 50);
    [_mooseView setImage:[UIImage imageNamed:@"moose"]];
    _mooseView.opaque = false;
    _mooseView.alpha = 1;
    
    _blackMask = [[UIView alloc] init];
    _blackMask.frame = CGRectMake(0 , 0, self.frame.size.width, self.frame.size.height);
    _blackMask.opaque = FALSE;
    _blackMask.backgroundColor = [UIColor blackColor];
    _blackMask.alpha = 0;
    [self addSubview:_blackMask];
    [self addSubview:_mooseView];
    [UIView animateWithDuration:ANIMATION_DURATION
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _mooseView.frame = CGRectMake(135, 70, 50, 50);
                         _blackMask.alpha = 0.8;

                     }
                     completion:^(BOOL finished){
                         [self endMooseAnimation];
                         
                     }];
    
}

-(void) endMooseAnimation{
    [UIView animateWithDuration:ANIMATION_DURATION*2.5
                          delay:ANIMATION_DELAY
                        options: (UIViewAnimationOptions)UIViewAnimationCurveEaseIn
                     animations:^{
                         _mooseView.alpha = 0;
                         _blackMask.alpha = 0;
                         
                     }
                     completion:^(BOOL finished){
                         [_mooseView removeFromSuperview];
                         [_blackMask removeFromSuperview];
                         
                     }];
}

// This is where we make the gradient mask on pictures
-(void) createGradient{
    // Flag tells whether it is a new start or a refreshing
    if(_gradientFlag == FALSE){
        CAGradientLayer *gradientBelow = [CAGradientLayer layer];
        gradientBelow.frame = CGRectMake(0 , 150, self.frame.size.width, self.frame.size.height - 150);
        gradientBelow.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                           (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], nil];
        CAGradientLayer *gradientRight = [CAGradientLayer layer];
        gradientRight.frame = CGRectMake(0 , 0, self.frame.size.width, self.frame.size.height - 150);
        gradientRight.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0] CGColor],
                                (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], nil];
        gradientRight.startPoint = CGPointMake(0.5, 0.5);
        gradientRight.endPoint =CGPointMake(1, 0);
        //[_postImageView.layer addSublayer:gradientRight]; //TODO: decide whether to leave gradient right on or off
        [_postImageView.layer addSublayer:gradientBelow];
        _gradientFlag = TRUE;
    }
}
@end
