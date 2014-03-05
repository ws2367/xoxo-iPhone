//
//  Location.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/4/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Institution;

@interface Location : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * remoteID;
@property (nonatomic, retain) NSDate * updateDate;
@property (nonatomic, retain) NSSet *institutions;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addInstitutionsObject:(Institution *)value;
- (void)removeInstitutionsObject:(Institution *)value;
- (void)addInstitutions:(NSSet *)values;
- (void)removeInstitutions:(NSSet *)values;

@end
