//
//  Location+MSLocation.m
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Location+MSLocation.h"

@implementation Location (MSLocation)

+ (BOOL)findOrCreateLocation:(NSString *)locationName returnAsLocation:(Location **) locationToReturn inManagedObjectContext:(NSManagedObjectContext *)context withError:(NSError *)err{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", locationName];
    NSArray *matches = [context
                        executeFetchRequest:request error:&err];

    // there should be only unique locations
    if (!matches || err || [matches count] > 1) {
        // handle error here
        NSLog(@"Errors in fetching locations");
        *locationToReturn = nil;
        return FALSE;
    } else if ([matches count]) {
        // found the thing, then set up relationship
        *locationToReturn = [matches firstObject];
        MSDebug(@"Found location %@", locationName);
        return TRUE;
    } else {
        // found nothing, and we don't create Location!!
        NSLog(@"Can't find this location in database, %@", locationName);
//        [Utility generateAlertWithMessage:@"No such state in America!" error:error];
        *locationToReturn = nil;
        return FALSE;
    }
}

@end
