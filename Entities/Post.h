//
//  Post.h
//  Cells
//
//  Created by Wen-Hsiang Shaw on 2/18/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSSet *entities;
@end

@interface Post (CoreDataGeneratedAccessors)

- (void)addEntitiesObject:(NSManagedObject *)value;
- (void)removeEntitiesObject:(NSManagedObject *)value;
- (void)addEntities:(NSSet *)values;
- (void)removeEntities:(NSSet *)values;

@end
