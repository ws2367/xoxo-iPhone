//
//  ServerConnector.m
//  Cells
//
//  Created by Wen-Hsiang Shaw on 10/28/13.
//  Copyright (c) 2013 WYY. All rights reserved.
//

#import "ServerConnector.h"
#import "CreatePostViewController.h"
#import "XOXOUIViewController.h"

@interface ServerConnector ()
@property (nonatomic, retain) NSArray * result;
@property (weak, nonatomic) XOXOUIViewController *viewController;
@end

@implementation ServerConnector




- (id)initWithURL:(NSString *)urlInString_
             verb:(NSString *)verb_
      requestType:(NSString *)requestType_
      responseType:(NSString *)responseType_
      timeoutInterval:(int)timeoutInterval_
 CreatePostViewController:(XOXOUIViewController *)clientViewController{
 
    
    //Consider not allocating spaces for NSString....
    _url          = [NSURL URLWithString:urlInString_];
    _verb         = [[NSString alloc] initWithString:verb_];
    _requestType  = [[NSString alloc] initWithString:requestType_];
    _responseType = [[NSString alloc] initWithString:responseType_];
    _timeoutInterval = timeoutInterval_;
    _viewController  = clientViewController;
    
    return self;
}

- (NSArray *) sendJSONGetJSONArray:(NSDictionary *)requestBody
{
    NSData *data;
    NSError *reqError = nil;
    
    if([NSJSONSerialization isValidJSONObject:requestBody]){
        data = [NSJSONSerialization dataWithJSONObject:requestBody options:NSJSONWritingPrettyPrinted error:&reqError];
    } else {
        NSLog(@"The request body is invalid");
    }
    
    if(reqError != nil){
        NSLog(@"Failed to serialize the NSDictionary!");
    }
    
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:_url
                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                            timeoutInterval:_timeoutInterval];
    
    [request setHTTPMethod:_verb];
    [request setValue:_requestType  forHTTPHeaderField:@"Content-type"];
    [request setValue:_responseType forHTTPHeaderField:@"Accept"];

    [request setHTTPBody:data];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    
    // create the session without specifying a queue to run completion handler on (thus, not main queue)
    // we also don't specify a delegate (since completion handler is all we need)
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
    
    NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request
                                                    completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error) {
                                                        // this handler is not executing on the main queue, so we can't do UI directly here
                                                        if (!error) {
                                                            NSError *reqError = nil;
                                                            NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfURL:localfile] options:NSJSONReadingMutableContainers error:&reqError];
                                                            
                                                            //[_viewController RefreshViewWithJSONArr:jsonArr];
                                                            
                                                            [_viewController performSelectorOnMainThread:@selector(RefreshViewWithJSONArr:) withObject:jsonArr waitUntilDone:NO];
                                                            
                                                            //[self performSelectorOnMainThread:@selector(gotItwithNSArray:) withObject:jsonArr waitUntilDone:NO];
                                                            //dispatch_async(dispatch_get_main_queue(), ^{ return   jsonArr; });

                                                            //if ([request.URL isEqual:self.imageURL]) {
                                                                // UIImage is an exception to the "can't do UI here"
                                                                //UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                                                                // but calling "self.image =" is definitely not an exception to that!
                                                                // so we must dispatch this back to the main queue
                                                                //dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                                                            //}
                                                        }
                                                    }];
    [task resume]; // don't forget that all NSURLSession tasks start out suspended!

    
    /*
    NSURLResponse *response = nil;
    NSError *resError = nil;
    NSData *result = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&resError];
    
    if(resError != nil){
        NSLog(@"%@", [resError localizedDescription]);
    }

    if(result != nil){
        NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableContainers error:&reqError];
        return jsonArr;
    }
    else{
        NSLog(@"It is nill!!!");
        return nil;
    }
     */
    
    return _result;
}   
/*
-(void) gotItwithNSArray:(NSArray *)res{
    if(_clientViewController){
        NSLog(@"getCalled?");
        [_clientViewController receiveNSArray: res];

    }
}
*/
@end
