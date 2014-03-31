//
//  Institution+MSInstitution.m
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Institution+MSInstitution.h"
#import "Location+MSLocation.h"

@implementation Institution (MSInstitution)

//for facebook user to find or create institution
+ (BOOL)findOrCreateInstitutionForFBUser:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Institution **)institutionToReturn inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Institution"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", institutionName];
    NSArray *matches = [context
                        executeFetchRequest:request error:&error];
    
    Location *thisLocation;
    BOOL hasFoundLocation = [Location findOrCreateLocation:locationName returnAsLocation:&thisLocation inManagedObjectContext:context withError:error];
    if(!matches || error){
        MSError(@"Errors in fetching institutions");
        *institutionToReturn = nil;
        return FALSE;
    } else if ([matches count]){
        if(hasFoundLocation){
            for(Institution *ins in matches){
                if(ins.location){
                    if([ins.location.name isEqualToString:thisLocation.name]){
                        *institutionToReturn = ins;
                        return TRUE;
                    }
                }
            }
            *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:thisLocation inManagedObjectContext:context];
            return FALSE;
        } else{
            for(Institution *ins in matches){
                if(!ins.location){
                    *institutionToReturn = ins;
                    return TRUE;
                }
            }
            *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:nil inManagedObjectContext:context];
            return FALSE;
        }
    } else{
        if(hasFoundLocation){
            *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:thisLocation inManagedObjectContext:context];
        } else{
            *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:nil inManagedObjectContext:context];
        }
        return FALSE;
    }
}


//for yours user to find or create institution
+ (BOOL)findOrCreateInstitutionForYoursUser:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Institution **) institutionToReturn inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Institution"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", institutionName];
    NSArray *matches = [context
                        executeFetchRequest:request error:&error];
    
    Location *thisLocation;
    BOOL hasFoundLocation = [Location findOrCreateLocation:locationName returnAsLocation:&thisLocation inManagedObjectContext:context withError:error];
    
    if(!matches || error){
        MSError(@"Errors in fetching institutions");
        *institutionToReturn = nil;
        return FALSE;
    } else if(!hasFoundLocation){
        // found nothing, and we don't create Location!!
        MSDebug(@"Can't find this location in database, %@", locationName);
        [Utility generateAlertWithMessage:@"No such state in America!" error:error];
        *institutionToReturn = nil;
        return FALSE;
    } else if([matches count]){
        for(Institution *ins in matches){
            if(ins.location){
                if([ins.location.name isEqualToString:thisLocation.name]){
                    *institutionToReturn = ins;
                    return TRUE;
                }
            }
        }
        *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:thisLocation inManagedObjectContext:context];
        return FALSE;
    } else{
        *institutionToReturn = [Institution createNewInstitution:institutionName withLocation:thisLocation inManagedObjectContext:context];
        return FALSE;
    }
}


+(Institution *)createNewInstitution:(NSString *)institutionName withLocation:(Location *)location inManagedObjectContext:(NSManagedObjectContext *)context{
    
    // found nothing, create it!
    Institution *ins = [NSEntityDescription insertNewObjectForEntityForName:@"Institution"
                                  inManagedObjectContext:context];
    
    [ins setName:institutionName];
    [ins setDirty:@YES];
    [ins setDeleted:@NO];
    [ins setUuid:[Utility getUUID]];
    if(location){
        [ins setLocation:location];
    }
    MSDebug(@"Created an institution with name %@", institutionName);
    return ins;
}
@end
