//
//  ViewPostDisplayContentTableViewCell.m
//  Cells
//
//  Created by Iru on 4/5/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayContentTableViewCell.h"

#import "UIColor+MSColor.h"

@interface ViewPostDisplayContentTableViewCell()

@property (strong, nonatomic) NSString *content;


@end

@implementation ViewPostDisplayContentTableViewCell

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

-(void) setContent:(NSString *)content andDate:(NSDate *)date{
    CGRect rectSize = [content boundingRectWithSize:(CGSize){WIDTH, CGFLOAT_MAX}
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                     attributes:[Utility getViewPostDisplayContentFontDictionary] context:nil];
    _content = content;
    NSAttributedString *contentText = [[NSAttributedString alloc]
                                          initWithString:_content attributes:[Utility getViewPostDisplayContentFontDictionary]];
    CGFloat textViewEnd = (rectSize.size.height+30);
    UITextView *contentTextView =[[UITextView alloc] initWithFrame:CGRectMake(0, 0, WIDTH, textViewEnd)];
    [contentTextView setAttributedText:contentText];
    [contentTextView setBackgroundColor:[UIColor colorForYoursWhite]];
    [contentTextView setEditable:NO];
    [contentTextView setSelectable:NO];
    [contentTextView setScrollEnabled:NO];
    [self.contentView addSubview:contentTextView];
    [self addOrangeLineStartAtY:textViewEnd];
    [self addDate:date atY:textViewEnd];
}

-(void) addDate:(NSDate *)date atY:(CGFloat) offsetY{
    NSAttributedString *dateStr = [[NSAttributedString alloc] initWithString:[Utility getDateToShow:date inWhole:YES] attributes:[Utility getViewPostDisplayContentDateFontDictionary]];
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, offsetY - 14, 70, 30)];
    [dateLabel setAttributedText:dateStr];
    [self.contentView addSubview:dateLabel];
}

-(void) addOrangeLineStartAtY:(CGFloat)offsetY{
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, 0.0f);
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(80, offsetY);
    CGPoint endPoint = CGPointMake(WIDTH, offsetY);
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
