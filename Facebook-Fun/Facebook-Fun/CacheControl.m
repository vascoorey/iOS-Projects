//
//  CacheControl.m
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CacheControl.h"
#import "NSString+MD5.h"

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
        NSError *error, *filePathsError;
        NSString *folderPath = [CacheControl folderPath];
        if(![fileManager fileExistsAtPath:folderPath])
        {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
            NSAssert(!error, @"ERROR: %@", [error description]);
        }
        NSArray *files = [fileManager contentsOfDirectoryAtPath:folderPath error:&error];
        NSArray *filePaths = [fileManager subpathsOfDirectoryAtPath:folderPath error:&filePathsError];
        NSAssert(!error && !filePathsError, @"ERROR: %@\n%@", [error description], [filePathsError description]);
        _identifiers = [[NSMutableSet alloc] initWithArray:files];
        for(NSString *filePath in filePaths)
        {
            NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:filePath] error:nil];
            _folderSize += [fileDictionary fileSize];
        }
        NSLog(@"Path: %@\nSize: %d", folderPath, _folderSize);
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

#define MAX_CACHE_IPHONE 8388608
#define MAX_CACHE_IPAD 33554432

+(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    NSString *filename = [identifier md5];
    NSAssert(![self containsIdentifier:filename], @"CacheControl already has this identifier: %@", filename);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *folderPath = [self folderPath];
    NSError *error;
    NSUInteger maxSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? MAX_CACHE_IPAD : MAX_CACHE_IPHONE);
    CacheControl *sharedControl = [self sharedControl];
    
    if(![fileManager fileExistsAtPath:folderPath])
    {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSAssert(!error, @"ERROR: %@", [error description]);

    [fileManager createFileAtPath:[folderPath stringByAppendingPathComponent:filename] contents:data attributes:nil];
    [sharedControl.identifiers addObject:filename];
    sharedControl.folderSize += [data length];
    while(sharedControl.folderSize >= maxSize)
    {
        [self removeOldestFile];
    }
    //NSLog(@"Added %@", identifier);
}

+(void)removeOldestFile
{
    NSError *filePathsError, *attributesError;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *filePaths = [fileManager subpathsOfDirectoryAtPath:[self folderPath] error:&filePathsError];
    NSAssert(!filePathsError, @"ERROR: %@", [filePathsError description]);
    NSDate *oldestDate = [NSDate date];
    NSString *oldestFile;
    for(NSString *filePath in filePaths)
    {
        //NSLog(@"Checking %@", filePath);
        NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[[self folderPath] stringByAppendingPathComponent:filePath] error:&attributesError];
        NSAssert(!attributesError, @"ERROR: %@", [attributesError description]);
        if([[fileDictionary fileModificationDate] compare:oldestDate] == NSOrderedAscending)
        {
            oldestDate = [fileDictionary fileModificationDate];
            oldestFile = filePath;
        }
    }
    NSAssert(oldestFile, @"ERROR: Couldn't find a file to delete!");
    //NSLog(@"Deleting: %@", oldestFile);
    [self removeIdentifierAndDeleteFile:oldestFile];
}

+(NSString *)folderPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // App's root folder
    return [documentsDirectory stringByAppendingPathComponent:@"FBFun"];
}

+(NSData *)fetchDataWithIdentifier:(NSString *)identifier
{
    NSString *filename = [identifier md5];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSData *data = [fileManager contentsAtPath:[[self folderPath] stringByAppendingPathComponent:filename]];
    return data;
}

+(BOOL)containsIdentifier:(NSString *)identifier
{
    return [[self sharedControl].identifiers containsObject:[identifier md5]];
}

+(void)removeIdentifierAndDeleteFile:(NSString *)identifier
{
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filename = [identifier md5];
    NSString *filePath = [[self folderPath] stringByAppendingPathComponent:filename];
    NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:filePath error:&error];
    NSAssert(!error, @"ERROR: %@", [error description]);
    [[self sharedControl].identifiers removeObject:filename];
    [self sharedControl].folderSize -= [fileDictionary fileSize];
}

@end
