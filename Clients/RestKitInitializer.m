//
//  RestKitInitializer.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 3/31/14.
//  Copyright (c) 2014 WYY. All rights reserved.
//

#import "RestKitInitializer.h"

// Entity classes
#import "Entity.h"
#import "Post.h"
#import "Comment.h"


@implementation RestKitInitializer

+ (void) setupWithObjectManager:(RKObjectManager *)objectManager inManagedObjectStore:(RKManagedObjectStore *)managedObjectStore{
    // you can do things like post.id too
    // set up mapping and response descriptor
   
    NSIndexSet *successCode = RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful);
    
    // entity mapping
    RKEntityMapping *entityMapping = [RKEntityMapping mappingForEntityForName:@"Entity" inManagedObjectStore:managedObjectStore];
    
    // 'fb' in fbUserID is not capitalized is because Core Data attributes have to start with small cases
    //
    [entityMapping addAttributeMappingsFromDictionary:@{@"id":              @"remoteID",
                                                        @"name":            @"name",
                                                        @"updated_at":      @"updateDate",
                                                        @"institution":     @"institution",
                                                        @"location":        @"location",
                                                        @"fb_user_id":      @"fbUserID",
                                                        
                                                        //meta attributes
                                                        @"is_your_friend":  @"isYourFriend"}];
    
    /* We map the entity by uuid. If it is an existing entity on the server side, we updateUUID after object mapping
     */
    entityMapping.identificationAttributes = @[@"fbUserID"];
    
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
                                                      @"updated_at":      @"updateDate",
                                                      
                                                      //meta attributes
                                                      @"is_yours":        @"isYours",
                                                      @"popularity":      @"popularity",
                                                      @"following":       @"following",
                                                      @"comments_count":  @"commentsCount",
                                                      @"followers_count": @"followersCount"}];
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
                                                             @"uuid":               @"uuid",
                                                             @"anonymized_user_id": @"anonymizedUserID",
                                                             @"updated_at":         @"updateDate"}];
    commentPOSTMapping.identificationAttributes = @[@"uuid"];
    
    RKResponseDescriptor *commentPOSTResponseDescriptor =
    [RKResponseDescriptor responseDescriptorWithMapping:commentPOSTMapping
                                                 method:RKRequestMethodPOST
                                            pathPattern:@"comments"
                                                keyPath:nil
                                            statusCodes:successCode];
    
    
    // When the modificationKey is non-nil, the mapper will compare the value returned for x`the key on an existing object instance with
    // the value in the representation being mapped. If they are exactly equal, then the mapper will skip all remaining property mappings
    // and proceed to the next object.
    //postMapping.modificationAttribute = [[NSEntityDescription entityForName:@"Post"
    //                                                 inManagedObjectContext:managedObjectStore.mainQueueManagedObjectContext] attributesByName][@"updateDate"];
    
    // add response descriptors to object manager
    [objectManager addResponseDescriptorsFromArray:@[entityWithPostPostResponseDescriptor,
                                                     postPostResponseDescriptor,
                                                     postResponseDescriptor, postOfEntityResponseDescriptor,
                                                     commentResponseDescriptor, commentPOSTResponseDescriptor,
                                                     commentOfPostResponseDescriptor]];
    
    /* Set up routing
     *
     */
    //First off, class routes
    RKRoute *postRoute        = [RKRoute routeWithClass:[Post class] pathPattern:@"posts" method:RKRequestMethodGET];
    
    RKRoute *postPOSTRoute    = [RKRoute routeWithClass:[Post class] pathPattern:@"posts" method:RKRequestMethodPOST];
    RKRoute *commentPOSTRoute = [RKRoute routeWithClass:[Comment class] pathPattern:@"comments" method:RKRequestMethodPOST];
    
    //secondly, relationship routes
    RKRoute *postCommentRelationshipRoute = [RKRoute routeWithRelationshipName:@"comments"
                                                                   objectClass:[Post class]
                                                                   pathPattern:@"posts/:remoteID/comments"
                                                                        method:RKRequestMethodGET];
    RKRoute *entityPostRelationshipRoute  = [RKRoute routeWithRelationshipName:@"posts"
                                                                   objectClass:[Entity class]
                                                                   pathPattern:@"entities/:remoteID/posts"
                                                                        method:RKRequestMethodGET];
    
    //Thirdly, named routes
    RKRoute *followPostRoute = [RKRoute routeWithName:@"follow_post" pathPattern:@"posts/:remoteID/follow" method:RKRequestMethodPOST];
    RKRoute *unfollowPostRoute = [RKRoute routeWithName:@"unfollow_post" pathPattern:@"posts/:remoteID/unfollow" method:RKRequestMethodDELETE];

    RKRoute *reportPostRoute = [RKRoute routeWithName:@"report_post" pathPattern:@"posts/:remoteID/report" method:RKRequestMethodPOST];
    RKRoute *sharePostRoute = [RKRoute routeWithName:@"share_post" pathPattern:@"posts/:remoteID/share" method:RKRequestMethodPOST];
    RKRoute *activatePostRoute = [RKRoute routeWithName:@"activate_post" pathPattern:@"posts/:remoteID/activate" method:RKRequestMethodPOST];

    RKRoute *inviteeRoute = [RKRoute routeWithName:@"report_inviter" pathPattern:@"invitations/inviter" method:RKRequestMethodPOST];
    
    RKRoute *sendDeviceTokenRoute = [RKRoute routeWithName:@"set_device_token" pathPattern:@"users/set_device_token" method:RKRequestMethodPOST];
    
    RKRoute *setBadgeRoute = [RKRoute routeWithName:@"set_badge" pathPattern:@"users/set_badge" method:RKRequestMethodPOST];
    
    [objectManager.router.routeSet addRoutes:@[// class routes
                                               postRoute, commentPOSTRoute, postPOSTRoute,
                                               // relationship routes
                                               postCommentRelationshipRoute, entityPostRelationshipRoute,
                                               // named routes
                                               followPostRoute, unfollowPostRoute, reportPostRoute, sharePostRoute,
                                               activatePostRoute, inviteeRoute, setBadgeRoute, sendDeviceTokenRoute]];
    
    /* Set up request descriptor
     *
     */
    
    RKObjectMapping *entitySerializationMapping = [RKObjectMapping requestMapping];
    [entitySerializationMapping addAttributeMappingsFromDictionary:@{@"name":            @"name",
                                                                     @"institution":     @"institution",
                                                                     @"location":        @"location",
                                                                     @"fbUserID":        @"fb_user_id",
                                                                     
                                                                     //meta attributes
                                                                     @"isYourFriend":    @"is_your_friend"}];
    
    RKRequestDescriptor *entityRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:entitySerializationMapping
                                          objectClass:[Entity class]
                                          rootKeyPath:@"Entity"
                                               method:RKRequestMethodPOST];
    
    RKObjectMapping *postSerializationMapping = [RKObjectMapping requestMapping];
    [postSerializationMapping addAttributeMappingsFromDictionary:@{@"content":         @"content",
                                                                   @"uuid":            @"uuid"}];
    
    RKRequestDescriptor *postRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:postSerializationMapping
                                          objectClass:[Post class]
                                          rootKeyPath:@"Post"
                                               method:RKRequestMethodPOST];
    
    RKObjectMapping *commentSerializationMapping = [RKObjectMapping requestMapping];
    
    [commentSerializationMapping addAttributeMappingsFromDictionary:@{@"content":    @"content",
                                                                      @"uuid":       @"uuid",
                                                                      @"postUUID":   @"post_uuid"}];
    
    
    RKRequestDescriptor *commentRequestDescriptor =
    [RKRequestDescriptor requestDescriptorWithMapping:commentSerializationMapping
                                          objectClass:[Comment class]
                                          rootKeyPath:@"Comment"
                                               method:RKRequestMethodPOST];
    
    [objectManager addRequestDescriptorsFromArray:@[postRequestDescriptor,
                                                    entityRequestDescriptor,
                                                    commentRequestDescriptor]];
    

}

@end
