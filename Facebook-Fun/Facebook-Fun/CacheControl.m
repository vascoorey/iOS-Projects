//
//  CacheControl.m
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CacheControl.h"
#import "Cache+Create.h"

@interface CacheControl ()
@property (nonatomic, strong) NSTimer *cleanupTimer;
@property (atomic, strong) NSManagedObjectContext *context;
@end

@implementation CacheControl

#warning Todo: clean up when cache expires or max size is passed.

#define MAX_CACHE_IPHONE 8388608
#define MAX_CACHE_IPAD 33554432

#pragma mark - Singleton

+(CacheControl *)sharedControl
{
    static CacheControl *sharedControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedControl = [[self alloc] init];
    });
    return sharedControl;
}

#pragma mark - CacheControl instance methods

// Returns nil if the identifier doesn't exist in cache
-(NSData *)fetchDataWithIdentifier:(NSString *)identifier
{
    return [Cache cacheWithIndentifier:identifier inManagegObjectContext:self.context create:NO].data;
}

// If the identifier already exists in cache this will replace it's data
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    [self pushDataToCache:data identifier:identifier expiration:nil];
}

// If still in cache after expiration date it will be deleted
// If the identifier already exists in cache this will replace it's data
-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier expiration:(NSDate *)expirationDate
{
    Cache *cache = [Cache cacheWithIndentifier:identifier inManagegObjectContext:self.context create:YES];
    cache.data = data;
    cache.identifier = identifier;
    cache.expirationDate = expirationDate;
    cache.size = @([data length]);
}

#pragma mark - Initialization

-(id)init
{
    if((self = [super init]))
    {
        [self useCacheDocument];
    }
    return self;
}

-(void)useCacheDocument
{
    NSAssert(!self.context, @"Attempting to load a document when one was already loaded!");
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"Caches"];
    UIManagedDocument *document = [[UIManagedDocument alloc] initWithFileURL:url];
    if(![[NSFileManager defaultManager] fileExistsAtPath:[url path]])
    {
        NSLog(@"Creating the demo document (%@)", [url path]);
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if(success)
            {
                self.context = document.managedObjectContext;
            }
            else
            {
                NSLog(@"Could not create the document at %@", url);
            }
        }];
    }
    else if(document.documentState == UIDocumentStateClosed)
    {
        [document openWithCompletionHandler:^(BOOL success) {
            if(success)
            {
                self.context = document.managedObjectContext;
            }
        }];
    }
    else
    {
        self.context = document.managedObjectContext;
    }
}

@end
