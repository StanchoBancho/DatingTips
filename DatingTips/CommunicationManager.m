//
//  CommunicationManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CommunicationManager.h"
#include "OpenUDID.h"
#import "NSString+Hashing.h"
#import "Constants.h"

static CommunicationManager* sharedManager = nil;

@interface CommunicationManager ()

@property (nonatomic, assign) dispatch_queue_t workingQueue;
@property (nonatomic, strong) NSString* password;
@property (nonatomic, strong) NSString* sessionId;
@end

@implementation CommunicationManager

+ (CommunicationManager*)sharedProvider
{
    if(!sharedManager){
        @synchronized(self){
            if(!sharedManager){
                sharedManager = [[super allocWithZone:NULL] init];
            }
        }
    }
    return sharedManager;
}

+(id)allocWithZone:(NSZone *)zone
{
    return [self sharedProvider];
}

- (id)init
{
    if (sharedManager){
        return sharedManager;
    }
    self = [super init];
    if (self) {
        self.workingQueue = dispatch_queue_create("DownloadingQueue", DISPATCH_QUEUE_SERIAL);
        NSString* myExistingPass =[[NSUserDefaults standardUserDefaults] objectForKey:@"pass"];
        if(myExistingPass){
            self.password = myExistingPass;
        }
    }
    return self;
}

#pragma mark - Utility Methods

- (void)askForPassword:(NSError**)error
{
    //create and send the request
    NSURL* url = [NSURL URLWithString:kURLAskForPassword];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString* deviceId = [OpenUDID value];
    NSString* appSecret = [[NSString stringWithFormat:@"%@%@", deviceId, kAppSecret] stingToSHA1];
    NSString* bodyString = [NSString stringWithFormat:@"id=%@&appSecret=%@",deviceId, appSecret];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyString length]] forHTTPHeaderField:@"Content-lenght"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* passwordData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    if(!*error){
        if(!passwordData){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get password data"}];
        }
        else{
            //parse the data
            NSError* parseError = nil;
            NSDictionary* json = [NSJSONSerialization JSONObjectWithData:passwordData options:NSJSONReadingAllowFragments error:&parseError];
            NSLog(@"passwordJson is:%@",json);
            if(parseError){
                *error = parseError;
                return;
            }
            NSNumber* requestStatus = [json objectForKey:@"status"];
            if(requestStatus && [requestStatus isEqual:@1]){
                NSString* password = [json objectForKey:@"pass"];
                if(password){
                    [self setPassword:password];
                    [[NSUserDefaults standardUserDefaults] setValue:password forKey:@"pass"];
                }
                else{
                    *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. There is no password."}];
                }
            }
            else{
                *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. The status is not 1"}];
            }
        }
    }
}

-(void)startSession:(NSError**)error
{
    //create and send the request
    NSURL* url = [NSURL URLWithString:kURLStartSession];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString* deviceId = [OpenUDID value];
    NSString* deviceIdAndPassSha1 = [[NSString stringWithFormat:@"%@%@", deviceId, self.password] stingToSHA1];
    NSString* bodyString = [NSString stringWithFormat:@"user=%@&pass=%@",deviceId, deviceIdAndPassSha1];
    [request setValue:[NSString stringWithFormat:@"%d", [bodyString length]] forHTTPHeaderField:@"Content-lenght"];
    [request setHTTPBody:[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
    NSData* sessionData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    if(!*error){
        if(!sessionData){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get session data"}];
            return;
        }
        //parse the data
        NSError* parseError = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:sessionData options:NSJSONReadingAllowFragments error:&parseError];
        if(parseError){
            *error = parseError;
            return;
        }
        NSLog(@"sessionJson is:%@",json);
        NSString* sessionId = [json objectForKey:@"sessionId"];
        if(sessionId){
            [self setSessionId:sessionId];
        }
        else{
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. There is no sessionId."}];
        }
    }
}

-(NSArray*)downloadTips:(NSError**)error
{
    //create and send the request for the tips
    NSURL* url = [NSURL URLWithString:kURLGetTips];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setValue:self.sessionId forHTTPHeaderField:@"X-APP-SESSION"];
    
    NSData* tipsData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    if(!*error){
        if(!tipsData){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get tips data"}];
            return nil;
        }
        //parse the data
        NSError* parseError = nil;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:tipsData options:NSJSONReadingAllowFragments error:&parseError];
        NSLog(@"tips data is:%@",json);
        
        NSArray* tips = [json objectForKey:@"tips"];
        if(!tips){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get tips data"}];
        }
        return tips;
    }
    return nil;
}

#pragma mark - Public Methods

- (void)getDailyTips:(void(^)(NSArray* tips, NSError* error))completion
{
    dispatch_sync(self.workingQueue, ^{
        
        //get pass if we have not any
        if(!self.password){
            NSError* passwordGetError = nil;
            [self askForPassword:&passwordGetError];
            if(!self.password || passwordGetError){
                if(completion){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, passwordGetError);
                    });
                }
                return;
            }
        }
        //get session id if we have not any
        if(!self.sessionId){
            NSError* sessionIdGetError = nil;
            [self startSession:&sessionIdGetError];
            if(!self.sessionId || sessionIdGetError){
                if(completion){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion(nil, sessionIdGetError);
                    });
                }
                return;
            }
        }
        
        //download tips
        NSError* downloadingTipsError = nil;
        NSArray* tips = [self downloadTips:&downloadingTipsError];
        if(!tips || downloadingTipsError){
            if(completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, downloadingTipsError);
                });
            }
        }
        else{
            if(completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(tips, nil);
                });
            }
        }
    });
}
@end
