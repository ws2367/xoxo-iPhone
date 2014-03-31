//
//  Entity+MSEntity.h
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Entity.h"

@interface Entity (MSEntity)

// if successfully found an entity, return true; else return false.
// assume there exist a findOrCreateInstitution: function in Institution Category

//for facebook user to find or create entity
+ (BOOL)findOrCreateEntityForFBUserName:(NSString *)entityName withFBid:(NSString *)fbid withInstitution:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Entity **) entityToReturn inManagedObjectContext:(NSManagedObjectContext *)context;

//for yours user to find or create institution
+ (BOOL)findOrCreateEntityForYoursUserName:(NSString *)entityName withInstitution:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Entity **) entityToReturn inManagedObjectContext:(NSManagedObjectContext *)context;

@end
