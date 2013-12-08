//
//  BIDNameAndColorCell.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "BigPostTableViewCell.h"

#define HEIGHT 568
#define WIDTH  320
#define ANIMATION_DURATION 0.4
#define ANIMATION_DELAY 0.0

@interface BigPostTableViewCell()
@property (weak, nonatomic) IBOutlet UIView *lowerMask;
@property (strong,nonatomic)  UIImageView *mooseView;
@property (strong,nonatomic)  UIView *blackMask;

@end

@implementation BigPostTableViewCell{
}



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [_lowerMask setAlpha:0.8];
        _lowerMask.opaque = FALSE;
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setContent:(NSString *)n
{
    if (![n isEqualToString:_content]) {
        _content = [n copy];
        //NSRange stringRange = {0,65};
        //if(_content.length > 65){
        //    _content = [_content substringWithRange:stringRange];
        //    _content = [_content stringByAppendingFormat:@"..."];
        //}
        _titleValue.text = _content;
    }
    
    _likeNum = 4;
    _hateNum = 3;
    _likeValue.text = [NSString stringWithFormat:@"%d", _likeNum];
    _hateValue.text = [NSString stringWithFormat:@"%d", _hateNum];
    
    _liked = false;
    _hated = false;
    [_likeButton setImage:[UIImage imageNamed:@"likeoff"] forState:UIControlStateNormal];
    [_hateButton setImage:[UIImage imageNamed:@"hateoff"] forState:UIControlStateNormal];

}

-(void) setEntities:(NSArray *)entities{
    NSLog(@"%@", entities);
    NSLog(@"%@", [entities objectAtIndex:0][@"name"]);
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

- (void)setEntity:(NSString *)c
{
    if (![c isEqualToString:_entity]) {
        _entity = [c copy];
        [_entityButton setTitle:_entity forState:UIControlStateNormal];
    }
}

- (void)setPic:(NSString *)c
{
    if (![c isEqualToString:_pic]) {
        _pic = [c copy];
        _myPic.image = [UIImage imageNamed:_pic];
    }
}

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


#pragma mark -
#pragma mark Button Methods




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


#pragma mark -
#pragma mark Swipe Methods
- (void) symptomCellSwipeLeft{
    
}
- (void) symptomCellSwipeRight{
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

@end
