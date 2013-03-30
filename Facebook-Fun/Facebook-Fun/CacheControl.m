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
@property (atomic) NSUInteger folderSize; // In bytes
@property (atomic, strong) NSTimer *cleanupTimer;
@end

@implementation CacheControl

-(id)init
{
    if((self = [super init]))
    {
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSError *error, *filePathsError;
        NSString *folderPath = [self folderPath];
        if(![fileManager fileExistsAtPath:folderPath])
        {
            [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
            NSAssert(!error, @"ERROR: %@", [error description]);
        }
        NSArray *filePaths = [fileManager subpathsOfDirectoryAtPath:folderPath error:&filePathsError];
        NSAssert(!error && !filePathsError, @"ERROR: %@\n%@", [error description], [filePathsError description]);
        for(NSString *filePath in filePaths)
        {
            NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[folderPath stringByAppendingPathComponent:filePath] error:nil];
            _folderSize += [fileDictionary fileSize];
        }
        [self startCleanupTimer];
        NSLog(@"Path: %@\nSize: %d", folderPath, _folderSize);
    }
    return self;
}

#define CLEANUP_INTERVAL 5 // Seconds

-(void)startCleanupTimer
{
    self.cleanupTimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(performCleanup:) userInfo:nil repeats:YES];
}

-(void)performCleanup:(NSTimer *)timer
{
    NSLog(@"Current size: %d", self.folderSize);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtURL:[NSURL URLWithString:[self folderPath]] includingPropertiesForKeys:@[NSURLCreationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
    
    if ([files count]){
        NSArray *sortedFileList = [files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSDate * mDate1 = nil;
            NSDate * mDate2 = nil;
            if ([(NSURL*)obj1 getResourceValue:&mDate1 forKey:NSURLCreationDateKey error:nil] &&
                [(NSURL*)obj2 getResourceValue:&mDate2 forKey:NSURLCreationDateKey error:nil]) {
                if ([mDate1 timeIntervalSince1970] < [mDate2 timeIntervalSince1970]) {
                    return (NSComparisonResult)NSOrderedDescending;
                }else{
                    return (NSComparisonResult)NSOrderedAscending;
                }
            }
            return (NSComparisonResult)NSOrderedSame; // there was an error in getting the value
        }];
        NSLog(@"%@", sortedFileList);
    }
}

#define MAX_CACHE_IPHONE 8388608
#define MAX_CACHE_IPAD 33554432

-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    NSString *filename = [identifier md5];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *folderPath = [self folderPath];
    NSError *error;
    
    if(![fileManager fileExistsAtPath:folderPath])
    {
        [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:NO attributes:nil error:&error];
    }
    NSAssert(!error, @"ERROR: %@", [error description]);

    [fileManager createFileAtPath:[folderPath stringByAppendingPathComponent:filename] contents:data attributes:nil];
    self.folderSize += [data length];
}

-(void)removeOldestFile
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

-(NSString *)folderPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // App's root folder
    return [documentsDirectory stringByAppendingPathComponent:@"FBFun"];
}

-(NSData *)fetchDataWithIdentifier:(NSString *)identifier
{
    NSString *filename = [identifier md5];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSData *data = [fileManager contentsAtPath:[[self folderPath] stringByAppendingPathComponent:filename]];
    return data;
}

-(void)removeIdentifierAndDeleteFile:(NSString *)identifier
{
    NSError *error;
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filename = [identifier md5];
    NSString *filePath = [[self folderPath] stringByAppendingPathComponent:filename];
    NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:filePath error:nil];
    [fileManager removeItemAtPath:filePath error:&error];
    NSAssert(!error, @"ERROR: %@", [error description]);
    self.folderSize -= [fileDictionary fileSize];
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

@end
