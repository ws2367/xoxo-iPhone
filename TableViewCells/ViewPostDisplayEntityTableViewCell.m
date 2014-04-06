//
//  ViewPostDisplayEntityCell.m
//  Cells
//
//  Created by Iru on 4/3/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "ViewPostDisplayEntityTableViewCell.h"
#import "Institution.h"
#import "UIColor+MSColor.h"

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
    _entity = en;
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 3, WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT*2/3)];
    NSAttributedString *nameWithFont = [[NSAttributedString alloc] initWithString:[_entity name] attributes:[Utility getViewPostDisplayEntityFontDictionary]];
    [nameLabel setAttributedText:nameWithFont];
    [self.contentView addSubview:nameLabel];
    
        if(_entity.institution){
        if(_entity.institution.name){
            UILabel *instiLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 18, WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT*2/3)];
            NSAttributedString *instiWithFont = [[NSAttributedString alloc] initWithString:_entity.institution.name attributes:[Utility getViewPostDisplayInstitutionFontDictionary]];
            [instiLabel setAttributedText:instiWithFont];
            [self.contentView addSubview:instiLabel];
        }
    }
    [self addDashLine];
}

-(void) addDashLine{
    CAShapeLayer *dashLineLayer=[[CAShapeLayer alloc] init];
    CGPoint startPoint = CGPointMake(0, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT);
    CGPoint endPoint = CGPointMake(WIDTH, VIEW_POST_DISPLAY_ENTITY_CELL_HEIGHT);
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
