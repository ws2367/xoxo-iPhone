//
//  MapPinAnnotation.m
//  Cells
//
//  Created by WYY on 13/10/24.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "MapPinAnnotation.h"

@implementation MapPinAnnotation

@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;
{
    self = [super init];
    if (self)
    {
        coordinate = location;
        title = placeName;
        subtitle = description;
    }
    
    return self;
}

@end
