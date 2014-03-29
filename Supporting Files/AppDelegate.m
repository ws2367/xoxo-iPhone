//
//  BIDAppDelegate.m
//  Cells
//
//  Created by WYY on 13/10/2.
//  Copyright (c) 2013年 WYY. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewMultiPostsViewController.h"

// Entity classes
#import "Location.h"
#import "Institution.h"
#import "Entity.h"
#import "Post.h"
#import "Comment.h"

#import "ClientManager.h"

//third party library
#import <FacebookSDK/FacebookSDK.h>

@implementation AppDelegate

@synthesize window = _window;
//@synthesize managedObjectContext = __managedObjectContext;
//@synthesize managedObjectModel = __managedObjectModel;
//@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSError *error = nil;
    NSManagedObjectModel *managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    RKManagedObjectStore *managedObjectStore = [[RKManagedObjectStore alloc] initWithManagedObjectModel:managedObjectModel];
    BOOL success = RKEnsureDirectoryExistsAtPath(RKApplicationDataDirectory(), &error);
    if (! success) {
        RKLogError(@"Failed to create Application Data Directory at path '%@': %@", RKApplicationDataDirectory(), error);
    }
    NSString *path = [RKApplicationDataDirectory() stringByAppendingPathComponent:@"Moose.sqlite"];
    NSPersistentStore *persistentStore = [managedObjectStore addSQLitePersistentStoreAtPath:path fromSeedDatabaseAtPath:nil withConfiguration:nil options:nil error:&error];
    if (! persistentStore) {
        RKLogError(@"Failed adding persistent store at path '%@': %@", path, error);
    }
    [managedObjectStore createManagedObjectContexts];
    
    
    // Set the default store shared instance
    [RKManagedObjectStore setDefaultStore:managedObjectStore];
    
    // configure the object manager
    // Let's let the URL end with '/' so later in response descriptors or routes we don't need to prefix path patterns with '/'
    // Remeber, evaluation of path patterns against base URL could be surprising.
    RKObjectManager *objectManager = [RKObjectManager managerWithBaseURL:[NSURL URLWithString:BASE_URL]];
    
    
    // DON'T EVER ADD FOLLOWING LINE because last time when I added it, ghost entities pop out everywhere...
    // THIS is kept here for the warning purpose
    //managedObjectStore.managedObjectCache = [[RKInMemoryManagedObjectCache alloc] initWithManagedObjectContext:managedObjectStore.persistentStoreManagedObjectContext];
    
    objectManager.managedObjectStore = managedObjectStore;
    // only accepts JSON from the server
    [objectManager setAcceptHeaderWithMIMEType:@"application/json"];
    [RKObjectManager setSharedManager:objectManager];
    
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
    
    NSIndexSet *successCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    RKResponseDescriptor *locationResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:locationMapping method:RKRequestMethodGET
                                            pathPattern:@"locations"
                                                keyPath:nil
                                            statusCodes:successCode];
    
    // institution mapping
    RKEntityMapping *institutionMapping = [RKEntityMapping mappingForEntityForName:@"Institution" inManagedObjectStore:managedObjectStore];
    [institutionMapping addAttributeMappingsFromDictionary:@{@"id": @"remoteID",
                                                             @"uuid": @"uuid",
                                                             @"name": @"name",
                                                             @"deleted": @"deleted",
                                                             @"location_id" :@"locationID",
                                                             @"updated_at": @"updateDate"}];
    institutionMapping.identificationAttributes = @[@"remoteID"];

    [institutionMapping addConnectionForRelationship:@"location" connectedBy:@{@"locationID":@"remoteID"}];
    
    RKResponseDescriptor *institutionWithPostPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:institutionMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"posts"
                                                keyPath:@"Institution"
                                            statusCodes:successCode];

    
    RKResponseDescriptor *institutionWithCommentResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:institutionMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"posts/:remoteID/comments"
                                                keyPath:@"Institution"
                                            statusCodes:successCode];

    RKResponseDescriptor *institutionWithPostOfEntityResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:institutionMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"entities/:remoteID/posts"
                                                keyPath:@"Institution"
                                            statusCodes:successCode];

    
    // entity mapping
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Entity" inManagedObjectStore:managedObjectStore];
    [entityMapping addAttributeMappingsFromDictionary:@{@"id":              @"remoteID",
                                                        @"name":            @"name",
                                                        @"uuid":            @"uuid",
                                                        @"deleted":         @"deleted",
                                                        @"updated_at":      @"updateDate",
                                                        //meta attributes
                                                        @"is_your_friend":  @"isYourFriend",
                                                        @"fb_user_id":      @"fbUserID"}];
    entityMapping.identificationAttributes = @[@"uuid"];

    [entityMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"institution"
                                                                                  toKeyPath:@"institution"
                                                                                withMapping:institutionMapping]];
    
    RKResponseDescriptor *entityResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"entities"
                                                keyPath:nil
                                            statusCodes:successCode];
    
    RKResponseDescriptor *entityWithPostPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:entityMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"posts"
                                                keyPath:@"Entity"
                                            statusCodes:successCode];

    
    // post mapping
    RKEntityMapping *postMapping = [RKEntityMapping mappingForEntityForName:@"Post" inManagedObjectStore:managedObjectStore];
    [postMapping addAttributeMappingsFromDictionary:@{
                                                      @"id":              @"remoteID",
                                                      @"content":         @"content",
                                                      @"uuid":            @"uuid",
                                                      @"deleted":         @"deleted",
                                                      @"updated_at":      @"updateDate",
                                                      //meta attributes
                                                      @"is_yours":         @"isYours",
                                                      @"popularity":      @"popularity",
                                                      @"following":       @"following"}];
    postMapping.identificationAttributes = @[@"uuid"];
    
    
    
    // Define the relationship mapping
    [postMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entities"
                                                                                toKeyPath:@"entities"
                                                                              withMapping:entityMapping]];
    RKResponseDescriptor *postResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"posts"
                                                keyPath:@"Post"
                                            statusCodes:successCode];
    
    RKResponseDescriptor *postPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"posts"
                                                keyPath:@"Post"
                                            statusCodes:successCode];

    RKResponseDescriptor *postOfEntityResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:postMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"entities/:remoteID/posts"
                                                keyPath:@"Post"
                                            statusCodes:successCode];
    

    // comment mapping
    RKEntityMapping *commentMapping = [RKEntityMapping mappingForEntityForName:@"Comment" inManagedObjectStore:managedObjectStore];
    [commentMapping addAttributeMappingsFromDictionary:@{@"id":                 @"remoteID",
                                                         @"content":            @"content",
                                                         @"uuid":               @"uuid",
                                                         @"anonymized_user_id": @"anonymizedUserID",
                                                         @"deleted":            @"deleted",
                                                         @"post_uuid":          @"postUUID",
                                                         @"updated_at":         @"updateDate"}];
    commentMapping.identificationAttributes = @[@"uuid"];
    
    [commentMapping addConnectionForRelationship:@"post" connectedBy:@{@"postUUID":@"uuid"}];
    
    RKResponseDescriptor *commentResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"comments"
                                                keyPath:nil
                                            statusCodes:successCode];
    
    RKResponseDescriptor *commentOfPostResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentMapping
                                                 method:RKRequestMethodGET
                                            pathPattern:@"posts/:remoteID/comments"
                                                keyPath:@"Comment"
                                            statusCodes:successCode];
    

    // So here comes the problem.. I spent one and half day debugging this.. :(
    // we CANNOT use the commentMapping used for GET requests to map responses from POST requests because
    // we don't include postUUID in the response from a POST request.
    // However, it would still try to connect the comment with a post because we added connection in commentMapping.
    // Since postUUID is not included in the response, it sets comment's relationship to the post NIL!!!!!!
    // Thus, we want to create another mapping without connection (relationship is taken cared of by Core Data
    // since it is saved locally) for POST requests.
    
    RKEntityMapping *commentPOSTMapping = [RKEntityMapping mappingForEntityForName:@"Comment"
                                                              inManagedObjectStore:managedObjectStore];
    
    // it's alright if you mapp attributes that will not be included in JSON response because mapping engine only updates
    // attributes included in JSON response. But again, DON'T ADD RELATIONSHIP CONNECTION if you are sure it's not included!
    [commentPOSTMapping addAttributeMappingsFromDictionary:@{@"id":                 @"remoteID",
                                                         @"content":            @"content",
                                                         @"uuid":               @"uuid",
                                                         @"anonymized_user_id": @"anonymizedUserID",
                                                         @"deleted":            @"deleted",
                                                         @"updated_at":         @"updateDate"}];
    commentPOSTMapping.identificationAttributes = @[@"uuid"];
    
    RKResponseDescriptor *commentPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentPOSTMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"comments"
                                                keyPath:nil
                                            statusCodes:successCode];
    
    
    // When the modificationKey is non-nil, the mapper will compare the value returned for the key on an existing object instance with
    // the value in the representation being mapped. If they are exactly equal, then the mapper will skip all remaining property mappings
    // and proceed to the next object.
    //postMapping.modificationAttribute = [[NSEntityDescription entityForName:@"Post"
    //                                                 inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext] attributesByName][@"updateDate"];
    
    // add response descriptors to object manager
    [objectManager addResponseDescriptorsFromArray:@[locationResponseDescriptor,
                                                     institutionWithCommentResponseDescriptor,
                                                     institutionWithPostPostResponseDescriptor,
                                                     institutionWithPostOfEntityResponseDescriptor,
                                                     entityWithPostPostResponseDescriptor,
                                                     entityResponseDescriptor, postPostResponseDescriptor,
                                                     postResponseDescriptor, postOfEntityResponseDescriptor,
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
    RKRoute *entityPostRelationshipRoute  = [RKRoute routeWithRelationshipName:@"posts"
                                                                   objectClass:[Entity class]
                                                                   pathPattern:@"entities/:remoteID/posts"
                                                                        method:RKRequestMethodGET];
    [objectManager.router.routeSet addRoutes:@[postCommentRelationshipRoute, entityPostRelationshipRoute]];
    
    //Thirdly, named routes
    RKRoute *pullAllRoute =[RKRoute routeWithName:@"pull_all" pathPattern:@"all" method:RKRequestMethodGET];
    RKRoute *followPostRoute = [RKRoute routeWithName:@"follow_post" pathPattern:@"posts/:remoteID/follow" method:RKRequestMethodPOST];
    RKRoute *unfollowPostRoute = [RKRoute routeWithName:@"unfollow_post" pathPattern:@"posts/:remoteID/unfollow" method:RKRequestMethodDELETE];
    
    [objectManager.router.routeSet addRoutes:@[pullAllRoute, followPostRoute, unfollowPostRoute]];
    
    
    /* Set up request descriptor
     *
     */

    RKObjectMapping *institutionSerializationMapping = [RKObjectMapping requestMapping];
    
    [institutionSerializationMapping addAttributeMappingsFromDictionary:@{@"remoteID": @"id",
                                                             @"uuid": @"uuid",
                                                             @"name": @"name",
                                                             @"locationID": @"location_id"}];
    
    RKRequestDescriptor *institutionRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:institutionSerializationMapping
                                          objectClass:[Institution class]
                                          rootKeyPath:@"Institution"
                                               method:RKRequestMethodPOST];
    
    RKObjectMapping *entitySerializationMapping = [RKObjectMapping requestMapping];
    [entitySerializationMapping addAttributeMappingsFromDictionary:@{@"remoteID":        @"id",
                                                                     @"name":            @"name",
                                                                     @"uuid":            @"uuid",
                                                                     //meta attributes
                                                                     @"isYourFriend":    @"is_your_friend",
                                                                     @"fbUserID":        @"fb_user_id",
                                                                     @"institutionUUID":  @"institution_uuid"}];
    
    RKRequestDescriptor *entityRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:entitySerializationMapping
                                          objectClass:[Entity class]
                                          rootKeyPath:@"Entity"
                                               method:RKRequestMethodPOST];
    
    RKObjectMapping *postSerializationMapping = [RKObjectMapping requestMapping];
    [postSerializationMapping addAttributeMappingsFromDictionary:@{@"remoteID":        @"id",
                                                                   @"content":         @"content",
                                                                   @"uuid":            @"uuid",
                                                                   @"entitiesUUIDs":   @"entities_uuids"}];

    RKRequestDescriptor *postRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:postSerializationMapping
                                          objectClass:[Post class]
                                          rootKeyPath:@"Post"
                                               method:RKRequestMethodPOST];
    
    RKObjectMapping *commentSerializationMapping = [RKObjectMapping requestMapping];
    
    [commentSerializationMapping addAttributeMappingsFromDictionary:@{@"remoteID":   @"id",
                                                                      @"content":    @"content",
                                                                      @"uuid":       @"uuid",
                                                                      @"postUUID":   @"post_uuid"}];

    
    RKRequestDescriptor *commentRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:commentSerializationMapping
                                          objectClass:[Comment class]
                                          rootKeyPath:@"Comment"
                                               method:RKRequestMethodPOST];
    
    [objectManager addRequestDescriptorsFromArray:@[institutionRequestDescriptor,
                                                    postRequestDescriptor,
                                                    entityRequestDescriptor,
                                                    commentRequestDescriptor]];
    
    
    /* Set up Facebook Login */
    // Whenever a person opens the app, check for a cached session
    
    // make sure that the FBLoginView class is loaded before the login view is shown.
    [FBLoginView class];
    
    
    /* Fetch location */
    NSString *timestamp = [self fetchLatestTimestampOfLocation];
    MSDebug(@"Location timestamp: %@", timestamp);
    
    NSDictionary *params = [NSDictionary dictionaryWithObject:timestamp forKey:@"timestamp"];

    [[RKObjectManager sharedManager] getObject:[Location alloc]
                                          path:nil
                                    parameters:params
                                       success:[Utility successBlockWithDebugMessage:@"Successfully loaded locations (states)" block:nil]
                                       failure:[Utility failureBlockWithAlertMessage:@"Can't download states!"]];
    
    /*Remove redundent data*/
    //TODO: remove objects in Core Data except for the first 5 in friends and following
    
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
    
    [FBAppCall handleDidBecomeActive];
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

#pragma mark - Facebook SDK methods
/**
 Processes the response from interacting with the Facebook login process
 */
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation{
    
    // Call FBAppCall's handleOpenURL:sourceApplication to handle Facebook app responses
    BOOL wasHandled = [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
    
    // You can add your app-specific url handling code here if needed
    
    return wasHandled;
}


#pragma mark - Miscellaneous Methods
- (NSString *) fetchLatestTimestampOfLocation{
    // get the latest updateDate
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Location"];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updateDate" ascending:NO];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [request setFetchLimit:1];
    
    
    NSArray *match = [[RKManagedObjectStore defaultStore].mainQueueManagedObjectContext executeFetchRequest:request error:nil];
    NSString *timestamp = nil;
    if ([match count] > 0) {
        Location *location = [match objectAtIndex:0];
        NSNumber *number = [NSNumber numberWithDouble:[location.updateDate timeIntervalSince1970]];
        timestamp = [number stringValue];
    } else {
        timestamp = [NSString stringWithFormat:@"0"];
    }
    return timestamp;
}


@end
