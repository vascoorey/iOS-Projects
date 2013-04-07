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

#define MAX_CACHE_IPHONE 8388608 // Bytes
#define MAX_CACHE_IPAD 33554432 // Bytes
#define CLEANUP_INTERVAL 60 // Seconds

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

#pragma mark - Initialization and Dealloc

-(id)init
{
    if((self = [super init]))
    {
        NSLog(@"Using cache document...");
        [self useCacheDocument];
        self.cleanupTimer = [NSTimer scheduledTimerWithTimeInterval:CLEANUP_INTERVAL target:self selector:@selector(performCleanup:) userInfo:nil repeats:YES];
    }
    return self;
}

-(void)useCacheDocument
{
    NSAssert(!self.context, @"Attempting to load a document when one was already loaded!");
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject];
    url = [url URLByAppendingPathComponent:@"FBFunCaches"];
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

-(void)dealloc
{
    [self.context save:nil];
    self.context = nil;
    [self.cleanupTimer invalidate];
    self.cleanupTimer = nil;
}

#pragma mark - CacheControl instance methods

// Returns nil if the identifier doesn't exist in cache
-(NSData *)dataWithIdentifier:(NSString *)identifier
{
    return [Cache cacheWithIndentifier:identifier inManagegObjectContext:self.context].data;
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
    Cache *cache = [Cache cacheWithIndentifier:identifier inManagegObjectContext:self.context];
    cache.data = data;
    cache.identifier = identifier;
    cache.expirationDate = expirationDate;
    cache.size = @([data length]);
    cache.timestamp = [NSDate date];
}

#pragma mark - Cleanup

-(void)performCleanup:(NSTimer *)timer
{
    // First get rid of any expired caches
    [self cleanExpiredCaches];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cache"];
    request.predicate = nil;
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES]];
    NSArray *cacheEntries = [self.context executeFetchRequest:request error:nil];
    NSUInteger totalSize = [[cacheEntries valueForKeyPath:@"@sum.size"] unsignedIntValue];
    NSLog(@"Total size: %d", totalSize);
    NSUInteger maxSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? MAX_CACHE_IPAD : MAX_CACHE_IPHONE;
    NSUInteger index = 0;
    while(totalSize > maxSize)
    {
        Cache *cacheToDelete = cacheEntries[index];
        NSLog(@"Deleting %@", cacheToDelete.identifier);
        totalSize -= [cacheToDelete.size unsignedIntValue];
        [cacheToDelete erase];
        index ++;
    }
    NSLog(@"Saving the current context...");
    [self.context save:nil];
}

-(void)cleanExpiredCaches
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Cache"];
    request.predicate = [NSPredicate predicateWithFormat:@"expirationDate < %@", [NSDate date]];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"identifier" ascending:YES]];
    NSArray *expiredEntries = [self.context executeFetchRequest:request error:nil];
    NSLog(@"Cleaning expired caches: %@", expiredEntries);
    [expiredEntries makeObjectsPerformSelector:@selector(erase)];
}

@end
