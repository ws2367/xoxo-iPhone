//
//  Institution+MSInstitution.h
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Institution.h"

@interface Institution (MSInstitution)

// if successfully found an institution, return true; else return false.
// assume there exist a findOrCreateLocation: function in Location Category

//for facebook user to find or create institution
+ (BOOL)findOrCreateInstitutionForFBUser:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Institution **) institutionToReturn inManagedObjectContext:(NSManagedObjectContext *)context;

//for yours user to find or create institution
+ (BOOL)findOrCreateInstitutionForYoursUser:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Institution **) institutionToReturn inManagedObjectContext:(NSManagedObjectContext *)context;
@end
