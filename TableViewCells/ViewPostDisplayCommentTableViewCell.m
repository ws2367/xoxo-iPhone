//
//  ViewPostDisplayCommentTableViewCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayCommentTableViewCell.h"
#import "UIColor+MSColor.h"
#import "Comment.h"

#define TIME_LABEL_TAG 2000
#define USER_IMAGE_TAG 2001
#define TIME_ICON_TAG 2002
#define COMMENT_TEXT_VIEW_TAG 2003
#define LINE_LAYER_TAG 2004


@interface ViewPostDisplayCommentTableViewCell()
@property (strong, nonatomic) Comment *myComment;
@property (strong, nonatomic) CAShapeLayer *dashLineLayer;
@end


@implementation ViewPostDisplayCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setComment:(Comment *)comment withIcon:(NSString *)fileString;{
    for(UIView *view in self.contentView.subviews){
        if(view.tag == USER_IMAGE_TAG || view.tag == COMMENT_TEXT_VIEW_TAG){
            [view removeFromSuperview];
        }
    }

    
    UIImage *userImage = [UIImage imageNamed:fileString];
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:userImage];
    [userImageView setFrame:CGRectMake(10, 0, userImage.size.width, userImage.size.height)];
    [userImageView setTag:USER_IMAGE_TAG];
     [self.contentView addSubview:userImageView];
    _myComment = comment;
    UITextView *commentTextView;
    if([[_myComment content] length]<25){
        NSAttributedString *commentText = [[NSAttributedString alloc]
                                           initWithString:[_myComment content] attributes:[Utility getViewPostDisplayCommentFontDictionary]];
        CGFloat textViewEnd = 30;
        commentTextView =[[UITextView alloc] initWithFrame:CGRectMake(60, 0, WIDTH-60, textViewEnd)];
        [commentTextView setAttributedText:commentText];
        [self addDarkBlueLineStartAtY:VIEW_POST_DISPLAY_COMMENT_HEIGHT -20];
    }else{
        CGRect rectSize = [[_myComment content] boundingRectWithSize:(CGSize){WIDTH-60, CGFLOAT_MAX}
                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:@{
                                                                       NSFontAttributeName : [UIFont systemFontOfSize:15]
                                                                       } context:nil];
        NSAttributedString *commentText = [[NSAttributedString alloc]
                                           initWithString:[_myComment content] attributes:[Utility getViewPostDisplayCommentFontDictionary]];
        CGFloat textViewEnd = ceil(rectSize.size.height)+20;
        commentTextView =[[UITextView alloc] initWithFrame:CGRectMake(60, 0, WIDTH-60, textViewEnd)];
        [commentTextView setAttributedText:commentText];
        CGFloat toStartLineY = textViewEnd-15;
        if(toStartLineY < VIEW_POST_DISPLAY_COMMENT_HEIGHT -20){
            [self addDarkBlueLineStartAtY:VIEW_POST_DISPLAY_COMMENT_HEIGHT -20];
        } else{
            [self addDarkBlueLineStartAtY:toStartLineY];
        }
    }
    [commentTextView setBackgroundColor:[UIColor clearColor]];
    [commentTextView setTag:COMMENT_TEXT_VIEW_TAG];
    [commentTextView setEditable:NO];
    [commentTextView setSelectable:NO];
    [commentTextView setScrollEnabled:NO];
    [self.contentView addSubview:commentTextView];
    [self addDate];

}

-(void) addDate{
    for(UIView *view in self.contentView.subviews){
        if(view.tag == TIME_LABEL_TAG || view.tag == TIME_ICON_TAG){
            [view removeFromSuperview];
        }
    }
    UIImage *timeIcon=[UIImage imageNamed:@"icon-clock.png"];
    UIImageView *timeIconView = [[UIImageView alloc] initWithImage:timeIcon];
    [timeIconView setFrame:CGRectMake(19, 42, timeIcon.size.width, timeIcon.size.height)];
    [timeIconView setTag:TIME_ICON_TAG];
    [self.contentView addSubview:timeIconView];
    NSAttributedString *dateStr = [[NSAttributedString alloc] initWithString:[Utility getDateToShow:[_myComment updateDate] inWhole:NO] attributes:[Utility getViewPostDisplayContentDateFontDictionary]];
    UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 39, 70, 20)];
    [timeLabel setTag:TIME_LABEL_TAG];
    [timeLabel setAttributedText:dateStr];
    [self.contentView addSubview:timeLabel];

    
}

-(void) addDarkBlueLineStartAtY:(CGFloat)Y{
    [_dashLineLayer removeFromSuperlayer];
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, 0.0f);
    _dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(60, Y);
    CGPoint endPoint = CGPointMake(WIDTH, Y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    
    UIColor *fill = [UIColor colorForYoursDarkBlue];
    _dashLineLayer.strokeStart = 0.0;
    _dashLineLayer.strokeColor = fill.CGColor;
    _dashLineLayer.lineWidth = 1.0;
    _dashLineLayer.lineJoin = kCALineJoinMiter;
    _dashLineLayer.path = path.CGPath;
    [_dashLineLayer setName:@"what?"];
    [self.contentView.layer addSublayer:_dashLineLayer];
}



@end
