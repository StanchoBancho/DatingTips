//
//  CoreDataManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/12/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CoreDataManager.h"

static CoreDataManager* sharedManager;
@interface CoreDataManager()

@property(nonatomic, copy) void(^setupCompletion)(UIManagedDocument* document, NSError *error);

@end

@implementation CoreDataManager

+ (CoreDataManager*)sharedManager
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
    return [self sharedManager];
}

- (id)init
{
    if (sharedManager){
        return sharedManager;
    }
    self = [super init];
    if (self) {
    }
    return self;
}

- (void)setupDocument:(void(^)(UIManagedDocument* document, NSError* error))completion
{
    self.setupCompletion = completion;
    [self setUpDocument:NO];
}


#pragma mark - Core Data Document Methods

- (void)documentReady:(UIManagedDocument *)document
{
    if(self.setupCompletion){
        self.setupCompletion(document, nil);
    }
}

- (void)reportDocumentOpenError
{
    UIAlertView* __alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"System Error", @"") message:[NSString stringWithFormat:NSLocalizedString(@"An unexpected error has occurred trying to create application data. Possible causes may be due to inadequate storage capacity or hardware failure.", @""), NSProcessInfo.processInfo.processName] delegate:nil cancelButtonTitle:NSLocalizedString(@"Quit", @"") otherButtonTitles:nil];
    
    //abort();
    
#warning  TO MAKE ABORT or something else
    [__alertView show];
}

- (void)setUpDocument:(BOOL)retry;
{
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"DatingTips"];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    
    self.document = [[UIManagedDocument alloc] initWithFileURL:url];
    // NSLog(@"Type of document %d", self.document.managedObjectContext );
    if (![fileManager fileExistsAtPath:[self.document.fileURL path]]) {
        // Not created on disk yet, so create it
        [self.document saveToURL:self.document.fileURL forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                [self documentReady:self.document];
                // [self startFetches];
            }
            else if (retry) {
                [self reportDocumentOpenError];
            }
            else {
                NSLog(@"Error creating document, deleting and starting over");
                self.document = nil;
                NSError *error = nil;
                if (![fileManager removeItemAtURL:url error:&error]) {
                    NSLog(@"Error deleting document: %@", error);
                    [self reportDocumentOpenError];
                }
                else {
                    [self setUpDocument:YES];
                }
            }
        }];
    }
	else if (self.document.documentState == UIDocumentStateClosed) {
        // Created on disk, so open it
        [self.document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                [self documentReady:self.document];
                //[self startFetches];
            }
            else if (retry) {
                [self reportDocumentOpenError];
            }
            else {
                DLog(@"Error opening document, deleting and starting over");
                self.document = nil;
                NSError *error = nil;
                if (![fileManager removeItemAtURL:url error:&error]) {
                    DLog(@"Error deleting document: %@", error);
                    [self reportDocumentOpenError];
                }
                else {
                    [self setUpDocument:YES];
                }
            }
        }];
    }
}

@end
