//
//  MapPinAnnotation.h
//  Cells
//
//  Created by WYY on 13/10/24.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapPinAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString* title;
@property (nonatomic, readonly) NSString* subtitle;

- (id)initWithCoordinates:(CLLocationCoordinate2D)location
                placeName:(NSString *)placeName
              description:(NSString *)description;

@end
