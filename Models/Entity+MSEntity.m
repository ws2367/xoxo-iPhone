//
//  Entity+MSEntity.m
//  Cells
//
//  Created by Iru on 3/30/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "Entity+MSEntity.h"

@implementation Entity (MSEntity)
+ (BOOL)findOrCreateEntityForFBUserName:(NSString *)entityName
                               withFBid:(NSString *)fbid
                        withInstitution:(NSString *)institutionName
                             atLocation:(NSString *)locationName
                         returnAsEntity:(Entity **)entityToReturn
                 inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    request.predicate = [NSPredicate predicateWithFormat:@"fbUserID = %@", fbid];
    NSArray *matches = [context
                        executeFetchRequest:request error:&error];
    
    MSDebug(@"Let's compare %@ and %@", fbid, [[matches firstObject] fbUserID]);
    
    if(!matches || error){
        MSError(@"Errors in fetching entity");
        *entityToReturn = nil;
        return FALSE;
    } else if([matches count]){
        *entityToReturn = [matches firstObject];
        return TRUE;
    } else {
        *entityToReturn = [Entity createNewFBUserEntity:fbid withEntityName:entityName withInstitution:institutionName atLocation:locationName inManagedObjectContext:context];
        return FALSE;
    }
    
}
/*
//for yours user to find or create institution
+ (BOOL)findOrCreateEntityForYoursUserName:(NSString *)entityName withInstitution:(NSString *)institutionName atLocationName:(NSString *) locationName returnAsInstitution:(Entity **) entityToReturn inManagedObjectContext:(NSManagedObjectContext *)context{
    
    NSError *error = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Entity"];
    request.predicate = [NSPredicate predicateWithFormat:@"name = %@", entityName];
    NSArray *matches = [context
                        executeFetchRequest:request error:&error];
    
    Institution *thisIns;
    [Institution findOrCreateInstitutionForFBUser:institutionName atLocationName:locationName returnAsInstitution:&thisIns inManagedObjectContext:context];
    
    if(!matches || error){
        MSError(@"Errors in fetching institutions");
        *entityToReturn = nil;
        return FALSE;
    } else if(!thisIns){
        *entityToReturn = nil;
        return FALSE;
        
    }  else if([matches count]){
        for(Entity *en in matches){
            if(en.institution){
                if(en.institution == thisIns){
                    *entityToReturn = en;
                    return TRUE;
                }
            }
        }
        *entityToReturn = [Entity createNewYoursEntity:entityName institution:thisIns inManagedObjectContext:context];
        return FALSE;
    } else{
        *entityToReturn = [Entity createNewYoursEntity:entityName institution:thisIns inManagedObjectContext:context];
        return TRUE;
    }
}*/

+(Entity *)createNewFBUserEntity:(NSString *)fbid
                  withEntityName:(NSString *)entityName
                 withInstitution:(NSString *)institutionName
                      atLocation:(NSString *)locationName
          inManagedObjectContext:(NSManagedObjectContext *)context{
    
    // found nothing, create it!
    Entity *en = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                               inManagedObjectContext:context];
    
    [en setFbUserID:fbid];
    [en setIsYourFriend:@YES];
    [en setDirty:@NO];
    [en setName:entityName];
    if (institutionName) [en setInstitution:institutionName];
    if (locationName) [en setLocation:locationName];

    MSDebug(@"Created an entity with name %@", entityName);
    return en;
}
/*
+(Entity *)createNewYoursEntity:(NSString *)entityName institution:(Institution *)institution inManagedObjectContext:(NSManagedObjectContext *)context{
    
    // found nothing, create it!
    Entity *en = [NSEntityDescription insertNewObjectForEntityForName:@"Entity"
                                  inManagedObjectContext:context];
    
    // set UUID
    [en setUuid:[Utility getUUID]];
    [en setDirty:@NO];
    [en setIsYourFriend:@YES];
    [en setName:entityName];
    if(institution){
        [en setInstitution:institution];
    }
    MSDebug(@"Created an entity with name %@", entityName);
    return en;
}*/

- (BOOL)updateUUIDinManagedObjectContext:(NSManagedObjectContext *)context{
    //TODO: implement this
    return YES;
}

@end
