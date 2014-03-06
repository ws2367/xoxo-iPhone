//
//  BIDAppDelegate.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewMultiPostsViewController.h"

// TODO: when we separate setting of Object Manager from here, we can remove following inclusion
#import "Location.h"
#import "Institution.h"
#import "Entity.h"
#import "Post.h"
#import "Comment.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize managedObjectContext = __managedObjectContext;
//@synthesize managedObjectModel = __managedObjectModel;
//@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    NSError *error = nil;
    NSURL *modelURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"Model" ofType:@"momd"]];
    // NOTE: Due to an iOS 5 bug, the managed object model returned is immutable.
    NSManagedObjectModel *managedObjectModel = [[[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL] mutableCopy];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    
    // Initialize the Core Data stack
    [managedObjectStore createPersistentStoreCoordinator];
    
    NSPersistentStore __unused *persistentStore = [managedObjectStore addInMemoryPersistentStore:&error];
    NSAssert(persistentStore, @"Failed to add persistent store: %@", error);
    
    [managedObjectStore createManagedObjectContexts];
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    // configure the object manager
    // Let's let the URL end with '/' so later in response descriptors or routes we don't need to prefix path patterns with '/'
    // Remeber, evaluation of path patterns against base URL could be surprising.
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:@"http://localhost:3000/"]];
    
    // TODO: Create another object manager that manages photo resources on S3
    
    objectManager.managedObjectStore = managedObjectStore;
    // only accepts JSON from the server
    [objectManager setAcceptHeaderWithMIMEType:@"application/json"];
    [RKObjectManager setSharedManager:objectManager];

    // Configure a managed object cache to ensure we do not create duplicate objects
    managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    // you can do things like post.id too
    // set up mapping and response descriptor
    // location mapping
    RKEntityMapping *locationMapping = [RKEntityMapping mappingForEntityForName:@"Location" inManagedObjectStore:managedObjectStore];
    [locationMapping addAttributeMappingsFromDictionary:@{@"id": @"remoteID",
                                                          @"name": @"name",
                                                          @"updated_at": @"updateDate"}];
    locationMapping.identificationAttributes = @[@"name"];

    /*
     * Evaluation of a relative URL (path pattern after replacing symbols) against a base URL can be surprising.
     * For ex, baseURL:@"http://example.com/v1/" and pathPattern: @"/foo" evaluate to @"http://example.com/foo"
     * However, baseURL:@"http://example.com/v1/" and pathPattern: @"foo/" or @"foo" evaluate to @"http://example.com/v1/foo"
     * Watch out for it!!!
     */
    RKResponseDescriptor *locationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:locationMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"locations"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // institution mapping
    RKEntityMapping *institutionMapping = [RKEntityMapping mappingForEntityForName:@"Institution" inManagedObjectStore:managedObjectStore];
    [institutionMapping addAttributeMappingsFromDictionary:@{@"id": @"remoteID",
                                                             @"name": @"name",
                                                             @"uuid": @"uuid",
                                                             @"deleted": @"deleted",
                                                             @"location_id" :@"locationID",
                                                             @"updated_at": @"updateDate"}];
    institutionMapping.identificationAttributes = @[@"uuid"];
    
    // set up connection description
    // As described in docs, entities are to managed objects what Class is to id, or—to use a database analogy—what tables are to rows.
    // we use a convenience method to get relationship description and add connection specifier to it
    // Each pair within the value for the connectedBy argument corresponds to an attribute pair in which the key is an attribute on the source entity
    // and the value is the destination entity.
    // In this example, locationID is in Institution (source) and remoteID is in Location (destination)
    // The argument for relationship is the name of the relationship to the mapping entity. In this case, institution is the mapping entity.
    // location is the name of the relationship to the entity Location for institution.
    [institutionMapping addConnectionForRelationship:@"location" connectedBy:@{@"locationID":@"remoteID"}];
    
    RKResponseDescriptor *institutionResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:institutionMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"institutions"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *institutionPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:institutionMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"institutions"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // entity mapping
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Entity" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{@"id":              @"remoteID",
                                                        @"name":            @"name",
                                                        @"uuid":            @"uuid",
                                                        @"deleted":         @"deleted",
                                                        @"institution_id":  @"institutionID",
                                                        @"updated_at":      @"updateDate"}];
    entityMapping.identificationAttributes = @[@"uuid"];
    
    [entityMapping addConnectionForRelationship:@"institution" connectedBy:@{@"institutionID":@"remoteID"}];
    
    RKResponseDescriptor *entityResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"entities"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *entityPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"entities"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    // post mapping
    RKEntityMapping *postMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:managedObjectStore];
    [postMapping addAttributeMappingsFromDictionary:@{
                                                        @"id":              @"remoteID",
                                                        @"content":         @"content",
                                                        @"uuid":            @"uuid",
                                                        @"deleted":         @"deleted",
                                                        @"isYours":         @"isYours",
                                                        @"entities_ids":    @"entitiesIDs",
                                                        @"updated_at":      @"updateDate"}];
    postMapping.identificationAttributes = @[@"uuid"];
    
    [postMapping addConnectionForRelationship:@"entities" connectedBy:@{@"entitiesIDs":@"remoteID"}];
    
    RKResponseDescriptor *postResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"posts"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *postPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"posts"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    
    // comment mapping
    RKEntityMapping *commentMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:managedObjectStore];
    [commentMapping addAttributeMappingsFromDictionary:@{@"id":                 @"remoteID",
                                                         @"content":            @"content",
                                                         @"uuid":               @"uuid",
                                                         @"anonymized_user_id": @"anonymizedUserID",
                                                         @"deleted":            @"deleted",
                                                         @"post_id":            @"postID",
                                                         @"updated_at":         @"updateDate"}];
    commentMapping.identificationAttributes = @[@"uuid"];
    
    [commentMapping addConnectionForRelationship:@"post" connectedBy:@{@"postID":@"remoteID"}];
    
    RKResponseDescriptor *commentResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"comments"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];

    RKResponseDescriptor *commentPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"comments"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    RKResponseDescriptor *commentOfPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"posts/:remoteID/comments"
                                                keyPath:nil
                                            statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    
    
    // When the modificationKey is non-nil, the mapper will compare the value returned for the key on an existing object instance with
    // the value in the representation being mapped. If they are exactly equal, then the mapper will skip all remaining property mappings
    // and proceed to the next object.
    //postMapping.modificationAttribute = [[NSEntityDescription entityForName:@"Post"
    //                                                 inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext] attributesByName][@"updateDate"];
    
    // add response descriptors to object manager
    [objectManager addResponseDescriptorsFromArray:@[locationResponseDescriptor,
                                                     institutionResponseDescriptor, institutionPOSTResponseDescriptor,
                                                     entityResponseDescriptor, entityPOSTResponseDescriptor,
                                                     postResponseDescriptor, postPOSTResponseDescriptor,
                                                     commentResponseDescriptor, commentPOSTResponseDescriptor,
                                                     commentOfPostResponseDescriptor]];
    
    /* Set up routing
     *
     */
    //First off, class routes
    RKRoute *locationRoute    = [RKRoute routeWithClass:[Location class] pathPattern:@"locations" method:RKRequestMethodGET];
    RKRoute *institutionRoute = [RKRoute routeWithClass:[Institution class] pathPattern:@"institutions" method:RKRequestMethodGET];
    RKRoute *entityRoute      = [RKRoute routeWithClass:[Entity class] pathPattern:@"entities" method:RKRequestMethodGET];
    RKRoute *postRoute        = [RKRoute routeWithClass:[Post class] pathPattern:@"posts" method:RKRequestMethodGET];
    RKRoute *commentRoute     = [RKRoute routeWithClass:[Comment class] pathPattern:@"comments" method:RKRequestMethodGET];
    
    RKRoute *institutionPOSTRoute = [RKRoute routeWithClass:[Institution class] pathPattern:@"institutions" method:RKRequestMethodPOST];
    RKRoute *entityPOSTRoute  = [RKRoute routeWithClass:[Entity class] pathPattern:@"entities" method:RKRequestMethodPOST];
    RKRoute *postPOSTRoute    = [RKRoute routeWithClass:[Post class] pathPattern:@"posts" method:RKRequestMethodPOST];
    RKRoute *commentPOSTRoute = [RKRoute routeWithClass:[Comment class] pathPattern:@"comments" method:RKRequestMethodPOST];

    [objectManager.router.routeSet addRoutes:@[locationRoute, institutionRoute, entityRoute, postRoute, commentRoute,
                                               institutionPOSTRoute, commentPOSTRoute, entityPOSTRoute, postPOSTRoute]];
    
    //secondly, relationship routes
    RKRoute *postCommentRelationshipRoute = [RKRoute routeWithRelationshipName:@"comments"
                                                                  objectClass:[Post class]
                                                                  pathPattern:@"posts/:remoteID/comments"
                                                                       method:RKRequestMethodGET];
    [objectManager.router.routeSet addRoute:postCommentRelationshipRoute];
    
    //Thirdly, named routes
    RKRoute *pullAllRoute =[RKRoute routeWithName:@"pull_all" pathPattern:@"all" method:RKRequestMethodGET];
    RKRoute *followPostRoute = [RKRoute routeWithName:@"follow_post" pathPattern:@"posts/:remoteID/follow" method:RKRequestMethodPOST];
    
    [objectManager.router.routeSet addRoutes:@[pullAllRoute, followPostRoute]];
    
    
    /* Set up request descriptor
     *
     */
    RKEntityMapping *institutionSerializationMapping = [institutionMapping inverseMapping];
    RKRequestDescriptor *institutionRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:institutionSerializationMapping
                                          objectClass:[Institution class]
                                          rootKeyPath:@"Institution"
                                               method:RKRequestMethodPOST];
    
    RKEntityMapping *entitySerializationMapping = [entityMapping inverseMapping];
    
    RKRequestDescriptor *entityRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:entitySerializationMapping
                                          objectClass:[Entity class]
                                          rootKeyPath:@"Entity"
                                               method:RKRequestMethodPOST];
    
    RKEntityMapping *postSerializationMapping = [postMapping inverseMapping];
    
    RKRequestDescriptor *postRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:postSerializationMapping
                                          objectClass:[Post class]
                                          rootKeyPath:@"Post"
                                               method:RKRequestMethodPOST];
    
    //TODO: actually... inverse mapping is bad because we don't want to send all the stuff back to server
    RKEntityMapping *commentSerializationMapping = [commentMapping inverseMapping];
    
    RKRequestDescriptor *commentRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:commentSerializationMapping
                                          objectClass:[Comment class]
                                          rootKeyPath:@"Comment"
                                               method:RKRequestMethodPOST];
    
    [objectManager addRequestDescriptorsFromArray:@[institutionRequestDescriptor, postRequestDescriptor,
                                                    entityRequestDescriptor, commentRequestDescriptor]];
    
    
    // set the transformable property image of Photo Entity to be allow external binary storage
    NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo"
                                                   inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext];
    NSAttributeDescription *imageAttribute = [[photoEntity attributesByName] objectForKey:@"image"];
    [imageAttribute setAllowsExternalBinaryDataStorage:YES];
    
    /* Set up view controller
     *
     */
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.viewController = [[ViewMultiPostsViewController alloc] initWithNibName:@"ViewMultiPostsViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    __managedObjectContext = managedObjectStore.mainQueueManagedObjectContext;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error])
        {*/
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
/*
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}*/


#pragma mark - Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
/*
- (NSManagedObjectContext *)managedObjectContext
{
    if (__managedObjectContext != nil)
    {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil)
    {
        __managedObjectContext = [[NSManagedObjectContext alloc] init];
        [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return __managedObjectContext;
}
*/
/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created from the application's model.
 */
/*
- (NSManagedObjectModel *)managedObjectModel
{
    if (__managedObjectModel != nil)
    {
        return __managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Model" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}*/

/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
/*
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (__persistentStoreCoordinator != nil)
    {
        return __persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Moose.sqlite"];
    
    NSError *error = nil;
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
    
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error])
    {*/
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
/*
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return __persistentStoreCoordinator;
}*/

#pragma mark - Application's Documents directory

/**
 Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
