//
//  ViewPostDisplayCommentTableViewCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayCommentTableViewCell.h"
#import "UIColor+MSColor.h"

@interface ViewPostDisplayCommentTableViewCell()
@property (strong, nonatomic) NSString *comment;
@end


@implementation ViewPostDisplayCommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addDarkBlueLine];
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) setComment:(NSString *)comment{
    UIImage *userImage = [UIImage imageNamed:@"icon-user.png"];
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:userImage];
    [userImageView setFrame:CGRectMake(10, 10, userImage.size.width, userImage.size.height)];
     [self.contentView addSubview:userImageView];
    _comment = comment;
    CGRect rectSize = [_comment boundingRectWithSize:(CGSize){WIDTH-70, CGFLOAT_MAX}
                                            options:NSStringDrawingUsesLineFragmentOrigin
                                         attributes:[Utility getViewPostDisplayCommentFontDictionary] context:nil];
    NSAttributedString *commentText = [[NSAttributedString alloc]
                                       initWithString:_comment attributes:[Utility getViewPostDisplayCommentFontDictionary]];
    CGFloat textViewEnd = (rectSize.size.height+10);
    UITextView *commentTextView =[[UITextView alloc] initWithFrame:CGRectMake(70, 10, WIDTH, textViewEnd)];
    [commentTextView setAttributedText:commentText];
    [commentTextView setEditable:NO];
    [commentTextView setSelectable:NO];
    [commentTextView setScrollEnabled:NO];
    [self.contentView addSubview:commentTextView];

}

-(void) addDarkBlueLine{
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(70, VIEW_POST_DISPLAY_COMMENT_HEIGHT);
    CGPoint endPoint = CGPointMake(WIDTH, VIEW_POST_DISPLAY_COMMENT_HEIGHT);
    UIBezierPath *path = [UIBezierPath bezierPath];
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    
    UIColor *fill = [UIColor colorForYoursDarkBlue];
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = fill.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.path = path.CGPath;
    [self.contentView.layer addSublayer:dashLineLayer];
}



@end
