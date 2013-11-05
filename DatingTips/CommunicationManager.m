//
//  CommunicationManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 5/27/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CommunicationManager.h"
#import "NSString+Hashing.h"
#import "Constants.h"
#import "NSData+AES.h"
#import <StoreKit/StoreKit.h>
#import "NSData+Base64.h"

static CommunicationManager* sharedManager = nil;
NSString* urlSecret;

@interface CommunicationManager ()

@property (nonatomic, strong) dispatch_queue_t workingQueue;
@property (atomic, strong) NSString* password;
@property (atomic, strong) NSString* sessionId;

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
        
        
        NSString* path = [[NSBundle mainBundle] pathForResource:@"default" ofType:@""];
        NSData* decodedData = [NSData dataWithContentsOfFile:path];
        NSData* ecryptedData =[decodedData decryptWithString:kPassCryptKey];
        urlSecret = [[NSString alloc] initWithData:ecryptedData encoding:NSUTF8StringEncoding];
        NSLog(@"S appsecret data is %@", urlSecret);
        
        
        //ask for saved token from the server if there is any
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
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* appSecret = [[NSString stringWithFormat:@"%@%@", deviceId, urlSecret] stingToSHA1];
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
                    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
                    [defaults setValue:password forKey:@"pass"];
                    [defaults synchronize];
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
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    NSString* deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
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

-(NSDictionary*)downloadTips:(NSError**)error
{
    //create and send the request for the tips
    NSURL* url = [NSURL URLWithString:kURLGetTips];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setValue:self.sessionId forHTTPHeaderField:@"X-APP-SESSION"];
    
    NSData* tipsData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    if(!*error){
        if(!tipsData){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get tips data"}];
            return nil;
        }
        //parse the data
        NSError* parseError = nil;
        NSString* string = [[NSString alloc] initWithData:tipsData encoding:NSUTF8StringEncoding];
        NSLog(@"the row data is %@", string);
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:tipsData options:NSJSONReadingMutableLeaves error:&parseError];
        NSLog(@"tips data is:%@",json);
        
        NSArray* tips = [json objectForKey:@"tips"];
        NSString* dateString = [json objectForKey: @"date"];
        if(!tips || !dateString){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get tips data"}];
            return nil;
        }
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [dateFormatter dateFromString:dateString];
        NSDictionary* result = @{@"tips":tips, @"date":date};
        return result;
    }
    return nil;
}

-(void)doOrdinarySecurityChecksAndRequestsIfNecessary:(NSError**)error
{
    NSError* passwordGetError = nil;
    //get pass if we have not any
    if(!self.password){
        [self askForPassword:&passwordGetError];
        if(!self.password || passwordGetError){
            *error = passwordGetError;
            return;
        }
    }
    //get session id if we have not any
    NSError* sessionIdGetError = nil;
    if(!self.sessionId){
        [self startSession:&sessionIdGetError];
        if(!self.sessionId || sessionIdGetError){
            *error = sessionIdGetError;
            return;
        }
    }
}


- (NSString*)base64forData:(NSData*)theData {
    const uint8_t* input = (const uint8_t*)[theData bytes];
    NSInteger length = [theData length];
    static char table[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
    NSMutableData* data = [NSMutableData dataWithLength:((length + 2) / 3) * 4];
    uint8_t* output = (uint8_t*)data.mutableBytes;
    NSInteger i;
    for (i=0; i < length; i += 3) {
        NSInteger value = 0;
        NSInteger j;
        for (j = i; j < (i + 3); j++) {
            value <<= 8;
            
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }
        NSInteger theIndex = (i / 3) * 4;
        output[theIndex + 0] =                    table[(value >> 18) & 0x3F];
        output[theIndex + 1] =                    table[(value >> 12) & 0x3F];
        output[theIndex + 2] = (i + 1) < length ? table[(value >> 6)  & 0x3F] : '=';
        output[theIndex + 3] = (i + 2) < length ? table[(value >> 0)  & 0x3F] : '=';
    }
    return [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
}

- (NSDictionary *) getDictionaryFromJsonString:(NSString *)jsonstring {
    NSError *jsonError;
    NSDictionary *dictionary = (NSDictionary *) [NSJSONSerialization JSONObjectWithData:[jsonstring dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
    if (jsonError) {
        dictionary = [[NSDictionary alloc] init];
    }
    return dictionary;
}


-(NSDictionary*)downloadPayedTips:(NSError**)error withReceiptData:(NSData*)receiptData
{
    //create and send the request for the tips
    NSURL* url = [NSURL URLWithString:kURLGetPayedTips];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setValue:self.sessionId forHTTPHeaderField:@"X-APP-SESSION"];

    //set the receipt
    //NSString* receiptDataString = [self base64forData:receiptData];
    
    NSString *receiptBase64String = [self encodeBase64:(uint8_t *)receiptData.bytes
                                             length:receiptData.length];

//    NSDictionary* dict = @{@"receipt-data":receiptBase64String};
//    NSData* jsonStringData =[NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    
    
    NSData* data = [receiptBase64String dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSString* requestBodyString = [NSString stringWithFormat:@"payment={\"receipt-data\" : \"%@\"}",jsonObjectString];
//    NSData* bodyData = [requestBodyString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    
    NSData* tipsData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:error];
    if(!*error){
        if(!tipsData){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get payed tips data"}];
            return nil;
        }
        //parse the data
        NSError* parseError = nil;
        NSString* string = [[NSString alloc] initWithData:tipsData encoding:NSUTF8StringEncoding];
        NSLog(@"the row data is %@", string);
        
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:tipsData options:NSJSONReadingMutableLeaves error:&parseError];
        NSLog(@"tips data is:%@",json);
        
        NSArray* tips = [json objectForKey:@"tips"];
        NSString* dateString = [json objectForKey: @"date"];
        if(!tips || !dateString){
            *error = [NSError errorWithDomain:@"CommunicationManager" code:0 userInfo:@{@"Info": @"We have some comunication problems. Can`t get payed tips data"}];
            return nil;
        }
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSDate* date = [dateFormatter dateFromString:dateString];
        NSDictionary* result = @{@"tips":tips, @"date":date};
        return result;
    }
    return nil;
}

#pragma mark
#pragma mark Base 64 encoding

- (NSString *)encodeBase64:(const uint8_t *)input length:(NSInteger)length
{
    NSData * data = [NSData dataWithBytes:input length:length];
    return [data base64EncodedString];
}


- (NSString *)decodeBase64:(NSString *)input length:(NSInteger *)length
{
    NSData * data = [NSData dataFromBase64String:input];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}

char* base64_encode(const void* buf, size_t size) {
    size_t outputLength;
    return NewBase64Encode(buf, size, NO, &outputLength);
}

void * base64_decode(const char* s, size_t * data_len)
{
    return NewBase64Decode(s, strlen(s), data_len);
}



#pragma mark - Public Methods

- (void)getDailyTips:(void(^)(NSArray* tips, NSDate* forDate, NSError* error))completion
{
    dispatch_sync(self.workingQueue, ^{
        
        //verify we have all the needed credentials
        NSError* error = nil;
        [self doOrdinarySecurityChecksAndRequestsIfNecessary:&error];
        if (error) {
            if(completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil, error);
                });
            }
            return;
        }
        
        //download tips
        NSError* downloadingTipsError = nil;
        NSDictionary* tipsInfo = [self downloadTips:&downloadingTipsError];
        if(!tipsInfo || downloadingTipsError){
            if(completion){
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(nil, nil, downloadingTipsError);
                });
            }
        }
        else{
            if(completion){
                NSArray* tips = [tipsInfo objectForKey:@"tips"];
                NSDate* date = [tipsInfo objectForKey:@"date"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(tips, date, nil);
                });
            }
        }
    });
}


- (void)getPayedTipsWithReceiptData:(NSData*)receiptData andCopletion:(void(^)(NSArray* tips, NSDate* forDate, NSError* error))completion
{
    //verify we have all the needed credentials
    NSError* error = nil;
    [self doOrdinarySecurityChecksAndRequestsIfNecessary:&error];
    if (error) {
        if(completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, error);
            });
        }
        return;
    }
    //download tips
    NSError* downloadingTipsError = nil;
    NSDictionary* tipsInfo = [self downloadPayedTips:&downloadingTipsError withReceiptData:receiptData];
    if(!tipsInfo || downloadingTipsError){
        if(completion){
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(nil, nil, downloadingTipsError);
            });
        }
    }
    else{
        if(completion){
            NSArray* tips = [tipsInfo objectForKey:@"tips"];
            NSDate* date = [tipsInfo objectForKey:@"date"];
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(tips, date, nil);
            });
        }
    }


}


@end
