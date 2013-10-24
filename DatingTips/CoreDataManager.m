//
//  CoreDataManager.m
//  DatingTips
//
//  Created by Stanimir Nikolov on 10/12/13.
//  Copyright (c) 2013 Stanimir Nikolov. All rights reserved.
//

#import "CoreDataManager.h"
#import <CoreData/CoreData.h>
#import "Tip.h"
#import "Tag.h"

static CoreDataManager* sharedManager;
@interface CoreDataManager()

@property(nonatomic, copy) void(^setupCompletion)(UIManagedDocument* document, NSError *error);

@end

@implementation CoreDataManager

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

#pragma mark - Public methods

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


- (void)setupDocument:(void(^)(UIManagedDocument* document, NSError* error))completion
{
    self.setupCompletion = completion;
    [self setUpDocument:NO];
}

-(void)setTagObjectWithTagTitle:(NSString*)tagTitle toTip:(Tip*)tip withAllTagsInTheContext:(NSMutableArray*)prevTags inContext:(NSManagedObjectContext*)context
{
    //check do we have such tag
    BOOL __block isTagExisting = NO;
    [prevTags enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Tag* prevTag = (Tag*)obj;
        if ([prevTag.tagTitle isEqualToString:tagTitle]) {
            //if we have such tag - ok use it
            [tip addTagsObject:prevTag];
            isTagExisting = YES;
            *stop = YES;
        }
    }];
    //if we do not have such tag create new and add it.
    if(!isTagExisting){
        Tag* newTag = (Tag*)[NSEntityDescription insertNewObjectForEntityForName:@"Tag" inManagedObjectContext:context];
        [newTag setTagTitle:tagTitle];
        [tip addTagsObject:newTag];
        [prevTags addObject:newTag];
    }

}

- (void)updateTipsWithJSONArray:(NSArray*)tipsArray forDate:(NSDate*)date
{
    NSManagedObjectContext* context = self.document.managedObjectContext;

    //fetch all existing tags
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tip"];
    NSError *error = nil;
    NSArray *prevTips = [context executeFetchRequest:request error:&error];
    
    //fetch all existing tags
    NSFetchRequest *tagRequest = [NSFetchRequest fetchRequestWithEntityName:@"Tag"];
    NSError *tagError = nil;
    NSMutableArray *prevTags = [[context executeFetchRequest:tagRequest error:&tagError] mutableCopy];
    
    NSMutableSet* allStillExistingsIds = [NSMutableSet set];
    //insert and update existings
    for (NSDictionary* tipData in tipsArray) {
        //check for existing tip
        NSString* tipId = [tipData objectForKey:@"id"];
        [allStillExistingsIds addObject:tipId];
        BOOL isExisting = NO;
        for (Tip* existingTip in prevTips) {
            if ([existingTip.tipId isEqualToString:tipId]) {
                //reset the description
                [existingTip setTipDescription:[tipData objectForKey:@"description"]];
                 //reset tags
                [existingTip removeTags:existingTip.tags];
                NSArray* tagsTitles = [tipData objectForKey:@"tags"];
                for(NSString* tagTitle in tagsTitles){
                    [self setTagObjectWithTagTitle:tagTitle toTip:existingTip withAllTagsInTheContext:prevTags inContext:context];
                }
                //do not reset the date
                isExisting = YES;
                break;
            }
        }
        //if such tip is not existing create new tip
        if (!isExisting){
            Tip* newTip = (Tip*)[NSEntityDescription insertNewObjectForEntityForName:@"Tip" inManagedObjectContext:context];
            [newTip setTipId:tipId];
            [newTip setDate:date];
            [newTip setTipDescription:[tipData objectForKey:@"description"]];
            //set tip tags
            NSArray* tagsTitles = [tipData objectForKey:@"tags"];
            for(NSString* tagTitle in tagsTitles){
                [self setTagObjectWithTagTitle:tagTitle toTip:newTip withAllTagsInTheContext:prevTags inContext:context];
            }
        }
    }
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
