//
//  Location.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/24/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Institution;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteId;
@property (nonatomic, retain) NSSet *institutions;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addInstitutionsObject:(Institution *)value;
- (void)removeInstitutionsObject:(Institution *)value;
- (void)addInstitutions:(NSSet *)values;
- (void)removeInstitutions:(NSSet *)values;

@end
