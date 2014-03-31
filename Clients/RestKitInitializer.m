//
//  RestKitInitializer.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/31/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "RestKitInitializer.h"

// Entity classes
#import "Location.h"
#import "Institution.h"
#import "Entity.h"
#import "Post.h"
#import "Comment.h"


@implementation RestKitInitializer

+ (void) setupWithObjectManager:(RKObjectManager *)objectManager inManagedObjectStore:(RKManagedObjectStore *)managedObjectStore{
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
    
    // 'fb' in fbUserID is not capitalized is because Core Data attributes have to start with small cases
    //
    [entityMapping addAttributeMappingsFromDictionary:@{@"id":              @"remoteID",
                                                        @"name":            @"name",
                                                        @"uuid":            @"uuid",
                                                        @"deleted":         @"deleted",
                                                        @"updated_at":      @"updateDate",
                                                        //meta attributes
                                                        @"is_your_friend":  @"isYourFriend",
                                                        @"fb_user_id":      @"fbUserID"}];
    
    /* If fbUserID is null, that means it is not on FB. Therefore, we map the objects by its UUIDs.
     * If fbUserID is not null, we map the objects by its fbUserID and we rewrite uuid in order to
     * maintain consistency.
     */
    entityMapping.identificationAttributes = @[@"fbUserID", @"uuid"];
    
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
                                                                   @"entitiesUUIDs":   @"entities_uuids",
                                                                   @"entitiesFBUserIDs":   @"entities_fb_user_ids"}];
    
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
    

}

@end
