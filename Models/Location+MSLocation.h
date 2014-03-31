//
//  Location+MSLocation.h
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Location.h"

@interface Location (MSLocation)
// if successfully found a location, return true; else return false.
+ (BOOL)findOrCreateLocation:(NSString *)locationName returnAsLocation:(Location **) locationToReturn inManagedObjectContext:(NSManagedObjectContext *)context withError:(NSError *)err;
@end
