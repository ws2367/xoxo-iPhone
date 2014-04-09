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

@interface ViewPostDisplayButtonBarTableViewCell()

@property (strong, nonatomic) UIButton *shareButton;
@property (strong, nonatomic) UIButton *commentButton;
@property (strong, nonatomic) UIButton *reportButton;
@property (strong, nonatomic) UIButton *whatButton;

@property (strong,nonatomic) UILabel *commentLabel;
@property (strong,nonatomic) UILabel *followLabel;
@property (strong, nonatomic) NSAttributedString *commentNumber;
@property (strong, nonatomic) NSAttributedString *followNumber;


@end

@implementation ViewPostDisplayButtonBarTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        [self addLowerButtons];
        [self addCommentAndFollowNumbersWithCommentNum:0 FollowNum:0];
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
    if(_delegate && [_delegate respondsToSelector:@selector(commentPost:)]){
        [_delegate commentPost:sender];
    }
}
-(void) followButtonPressed:(id)sender{
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
-(void) addCommentAndFollowNumbersWithCommentNum:(NSInteger *)commentNum FollowNum:(NSInteger *)followNum{
    _commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(102, BUTTON_BAR_ORIGIN_Y+5, 50, 18)];
    _followLabel = [[UILabel alloc] initWithFrame:CGRectMake(184, BUTTON_BAR_ORIGIN_Y+5, 50, 18)];
    _commentNumber = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)commentNum] attributes:[Utility getCommentNumberFontDictionary]];
    _followNumber = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%d", (int)followNum] attributes:[Utility getFollowNumberFontDictionary]];
    [_commentLabel setAttributedText:_commentNumber];
    [_followLabel setAttributedText:_followNumber];
    [self.contentView addSubview:_commentLabel];
    [self.contentView addSubview:_followLabel];
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
