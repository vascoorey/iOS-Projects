//
//  CacheControl.m
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CacheControl.h"

#define CACHE_DIR @"SPoTCache"

@interface CacheControl ()
@property (atomic, strong) NSMutableSet *identifiers;
@property (atomic) NSUInteger folderSize; // In bytes
@end

@implementation CacheControl

-(id)init
{
    if((self = [super init]))
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *error, *attributesError;
        NSString *folderPath = [CacheControl folderPath];
        NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:&error];
        NSDictionary *attributes = [fileManager attributesOfItemAtPath:folderPath error:&attributesError];
        NSAssert(!error && !attributesError, @"ERROR: %@\n%@", [error description], [attributesError description]);
        _identifiers = [[NSMutableSet alloc] initWithArray:files];
        _folderSize = [attributes fileSize];
        NSLog(@"%@", _identifiers);
        NSLog(@"%d", _folderSize);
    }
    return self;
}

+(CacheControl *)sharedControl
{
    static CacheControl *sharedControl = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedControl = [[CacheControl alloc] init];
    });
    return sharedControl;
}

+(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    NSAssert(![self containsIdentifier:identifier], @"CacheControl already has this identifier: %@", identifier);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *folderPath = [self folderPath];
    NSError *error;
    if(![fileManager fileExistsAtPath:folderPath])
    {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSAssert(!error, @"ERROR: %@", [error description]);
    NSLog(@"Folder: %@", [folderPath stringByAppendingPathComponent:identifier]);
    [fileManager createFileAtPath:[folderPath stringByAppendingPathComponent:identifier] contents:data attributes:nil];
    [[self sharedControl].identifiers addObject:identifier];
    NSLog(@"Added %@", identifier);
}

+(NSString *)folderPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // App's root folder
    return [documentsDirectory stringByAppendingPathComponent:CACHE_DIR];
}

+(NSData *)getDataFromCache:(NSString *)identifier
{
    NSAssert([self containsIdentifier:identifier], @"Can't get contents for identifier: %@", identifier);
    NSLog(@"Fetching %@", identifier);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSData *data = [fileManager contentsAtPath:[[self folderPath] stringByAppendingPathComponent:identifier]];
    return data;
}

+(BOOL)containsIdentifier:(NSString *)identifier
{
    return [[self sharedControl].identifiers containsObject:identifier];
}

+(void)removeIdentifierAndDeleteFile:(NSString *)identifier
{
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    [fileManager removeItemAtPath:[[self folderPath] stringByAppendingPathComponent:identifier] error:&error];
    NSAssert(!error, @"ERROR: %@", [error description]);
    [[self sharedControl].identifiers removeObject:identifier];
}

@end
