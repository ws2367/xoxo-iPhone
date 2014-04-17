//
//  ViewPostDisplayButtonBarCell.m
//  Cells
//
//  Created by Iru on 4/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayButtonBarTableViewCell.h"
#import "UIColor+MSColor.h"

#define BUTTON_BAR_ORIGIN_Y 12
#define FOLLOW_LABEL_TAG 1000
#define COMMENT_LABEL_TAG 1001

@interface ViewPostDisplayButtonBarTableViewCell()

@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *reportButton;
@property (strong, nonatomic) UIButton *whatButton;

@property (strong,nonatomic) UILabel *commentLabel;
@property (strong,nonatomic) UILabel *followLabel;
@property (strong, nonatomic) NSAttributedString *commentString;
@property (strong, nonatomic) NSAttributedString *followString;

@property (nonatomic) BOOL hasFollowed;
@property (nonatomic) NSInteger followNumber;
@property (nonatomic) NSInteger commentNumber;




@end

@implementation ViewPostDisplayButtonBarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addLowerButtons];
//        [self addCommentAndFollowNumbersWithCommentNum:0 FollowNum:0];
        [self addOrangeLine];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


#pragma mark -
#pragma mark Button Methods
-(void) shareButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(sharePost:)]){
        [_delegate sharePost:sender];
    }
}
-(void) commentButtonPressed:(id)sender{
    [_commentLabel removeFromSuperview];
    if(_delegate && [_delegate respondsToSelector:@selector(commentPost:)]){
        [_delegate commentPost:sender];
    }
}
-(void) followButtonPressed:(id)sender{
    for(UIView *view in self.contentView.subviews){
        if(view.tag == FOLLOW_LABEL_TAG){
            [view removeFromSuperview];
        }
    }
    if(_hasFollowed){
        _followNumber--;
        NSAttributedString *String = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", _followNumber] attributes:[Utility getFollowNumberFontDictionary]];
        [_followLabel setAttributedText:String];
        [_whatButton setImage:[UIImage imageNamed:@"icon-follow.png"] forState:UIControlStateNormal];
        _hasFollowed = FALSE;
        [self.contentView addSubview:_followLabel];
    }else{
        _followNumber++;
        NSAttributedString *String = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", _followNumber] attributes:[Utility getFollowNumberFontDictionary]];
        [_followLabel setAttributedText:String];
        [_whatButton setImage:[UIImage imageNamed:@"icon-followII.png"] forState:UIControlStateNormal];
        _hasFollowed = TRUE;
        [self.contentView addSubview:_followLabel];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(followPost:)]){
        [_delegate followPost:sender];
    }
}
-(void) reportButtonPressed:(id)sender{
    if(_delegate && [_delegate respondsToSelector:@selector(reportPost:)]){
        [_delegate reportPost:sender];
    }
}


# pragma mark -
#pragma mark Add UI Buttons
- (void)addLowerButtons{
    _shareButton = [self createLowerButtonAtOriginX:15 andY:BUTTON_BAR_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newshare.png"]];
    _commentButton = [self createLowerButtonAtOriginX:64 andY:BUTTON_BAR_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newcomment.png"]];
    _whatButton = [self createLowerButtonAtOriginX:150 andY:BUTTON_BAR_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-follow.png"]];
    _reportButton = [self createLowerButtonAtOriginX:285 andY:BUTTON_BAR_ORIGIN_Y withImage:[UIImage imageNamed:@"icon-newreport.png"]];
    [self createVerticalLineAtOriginX:98 andY:BUTTON_BAR_ORIGIN_Y+5 withColor:[UIColor colorForYoursBlue]];
    [self createVerticalLineAtOriginX:180 andY:BUTTON_BAR_ORIGIN_Y+5 withColor:[UIColor colorForYoursOrange]];
    [_shareButton addTarget:self action:@selector(shareButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_whatButton addTarget:self action:@selector(followButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [_reportButton addTarget:self action:@selector(reportButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
}

-(UIButton *)createLowerButtonAtOriginX:(int)originX andY:(int)originY withImage:(UIImage *)buttonImage{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    button.frame = CGRectMake(originX, originY, buttonImage.size.width, buttonImage.size.height);
    [button setBackgroundImage:buttonImage forState:UIControlStateNormal];
    [self.contentView addSubview:button];
    return button;
}

-(void) createVerticalLineAtOriginX:(int)originX andY:(int)originY withColor:(UIColor *)lineColor{
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(originX, originY);
    CGPoint endPoint = CGPointMake(originX, originY + 18);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = lineColor.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    [self.contentView.layer addSublayer:dashLineLayer];
}
-(void) addCommentAndFollowNumbersWithCommentsCount:(NSNumber *)commentsCount FollowersCount:(NSNumber *)followersCount hasFollowed:(BOOL)hasFollowed{
    _followNumber = [followersCount integerValue];
    _commentNumber = [commentsCount integerValue];
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(102, BUTTON_BAR_ORIGIN_Y+5, 50, 18)];
    _followLabel = [[UILabel alloc] initWithFrame:CGRectMake(184, BUTTON_BAR_ORIGIN_Y+5, 50, 18)];
    _commentString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [commentsCount integerValue]] attributes:[Utility getCommentNumberFontDictionary]];
    _followString = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", [followersCount integerValue]] attributes:[Utility getFollowNumberFontDictionary]];
    [_commentLabel setAttributedText:_commentString];
    [_followLabel setAttributedText:_followString];
    [_commentLabel setTag:COMMENT_LABEL_TAG];
    [_followLabel setTag:FOLLOW_LABEL_TAG];
    [_followLabel removeFromSuperview];
    [_commentLabel removeFromSuperview];
    [self.contentView addSubview:_commentLabel];
    [self.contentView addSubview:_followLabel];
    if(hasFollowed){
        [_whatButton setImage:[UIImage imageNamed:@"icon-followII.png"] forState:UIControlStateNormal];
    }else{
        [_whatButton setImage:[UIImage imageNamed:@"icon-follow.png"] forState:UIControlStateNormal];
    }
    _hasFollowed = hasFollowed;
    
}

-(void) addOrangeLine{
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, 0.0f);
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(0, VIEW_POST_DISPLAY_BUTTON_BAR_HEIGHT);
    CGPoint endPoint = CGPointMake(WIDTH, VIEW_POST_DISPLAY_BUTTON_BAR_HEIGHT);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    
    UIColor *fill = [UIColor colorForYoursOrange];
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = fill.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    [self.contentView.layer addSublayer:dashLineLayer];
}



@end
