//
//  ViewPostDisplayEntityCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayEntityTableViewCell.h"
#import "UIColor+MSColor.h"

#define NAME_INSTI_TAG 4321

@interface ViewPostDisplayEntityTableViewCell()
@property(strong,nonatomic) Entity *entity;
@end

@implementation ViewPostDisplayEntityTableViewCell

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

-(void)layoutSubviews{
    
}

-(void) setEntity:(Entity *)en{
    for(UIView *view in self.contentView.subviews){
        if(view.tag == NAME_INSTI_TAG){
            [view removeFromSuperview];
        }
    }
    _entity = en;
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT*2/3)];
    NSAttributedString *nameWithFont = [[NSAttributedString alloc] initWithString:[_entity name] attributes:[Utility getViewPostDisplayEntityFontDictionary]];
    [nameLabel setAttributedText:nameWithFont];
    [nameLabel setTag:NAME_INSTI_TAG];
    [self.contentView addSubview:nameLabel];
    
    if(_entity.institution){
        UILabel *instiLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 18, WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT*2/3)];
        NSAttributedString *instiWithFont = [[NSAttributedString alloc] initWithString:_entity.institution attributes:[Utility getViewPostDisplayInstitutionFontDictionary]];
        [instiLabel setAttributedText:instiWithFont];
        [instiLabel setTag:NAME_INSTI_TAG];
        [self.contentView addSubview:instiLabel];
    }
    
    [self addArrow];
    [self addDashLine];
}

-(void) addArrow{
    UIImage *arrowImage = [UIImage imageNamed:@"icon-arrow"];
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:arrowImage];
    [arrowImageView setFrame:CGRectMake(WIDTH-40, 10, arrowImage.size.width, arrowImage.size.height)];
    [self.contentView addSubview:arrowImageView];
}

-(void) addDashLine{
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(0, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT);
    CGPoint endPoint = CGPointMake(WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT);
    
    UIGraphicsBeginImageContextWithOptions(self.contentView.bounds.size, NO, 0.0f);
    //CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextBeginPath (context);
    //CGContextMoveToPoint(context, 0, 0);
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    //draw a line
    [path moveToPoint:startPoint]; //add yourStartPoint here
    [path addLineToPoint:endPoint];// add yourEndPoint here
    [path stroke];
    
    float dashPattern[] = {1,1}; //make your pattern here
    [path setLineDash:dashPattern count:2 phase:0];
    
    UIColor *fill = [UIColor colorForYoursDashLine];
    dashLineLayer.strokeStart = 0.0;
    dashLineLayer.strokeColor = fill.CGColor;
    dashLineLayer.lineWidth = 1.0;
    dashLineLayer.lineJoin = kCALineJoinMiter;
    dashLineLayer.lineDashPattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:5],[NSNumber numberWithInt:5], nil];
    dashLineLayer.lineDashPhase = 3.0f;
    dashLineLayer.path = path.CGPath;
    [self.contentView.layer addSublayer:dashLineLayer];
}

@end
