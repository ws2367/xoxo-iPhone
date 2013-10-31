//
//  EntityCell.h
//  Cells
//
//  Created by WYY on 13/10/17.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EntityCell : UITableViewCell

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *institution;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *pic;


@property (weak, nonatomic) IBOutlet UIImageView *myPic;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *institutionLabel;

@end
