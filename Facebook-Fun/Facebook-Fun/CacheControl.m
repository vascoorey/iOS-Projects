//
//  CacheControl.m
//  SPoT
//
//  Created by Vasco Orey on 2/28/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "CacheControl.h"
#import "NSString+MD5.h"
#import "NSData+MD5.h"

@interface CacheControl ()
@property (atomic) NSUInteger folderSize; // In bytes
@property (nonatomic, strong) NSTimer *cleanupTimer;
@property (nonatomic, strong) NSString *expirationsFile;
@property (nonatomic, strong) NSString *lastExpirationsFileDataDigest;
@property (nonatomic, strong) NSMutableDictionary *expirations;
@end

@implementation CacheControl

#warning Refactor CacheControl: Use CoreData
#define EXPIRATION_FILE @"FBFUN_EXPIRATIONS"
#define EXPIRATION_HASH_FILE @"-HASH"

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
        [self loadExpirations];
        [self startCleanupTimer];
        NSLog(@"Path: %@\nSize: %d", folderPath, _folderSize);
    }
    return self;
}

-(NSString *)expirationsFile
{
    if(!_expirationsFile)
    {
        _expirationsFile = [[self folderPath] stringByAppendingPathComponent:EXPIRATION_FILE];
    }
    return _expirationsFile;
}

-(void)loadExpirations
{
    NSData *data = [NSData dataWithContentsOfFile:self.expirationsFile];
    if(data)
    {
        NSData *hashData = [NSData dataWithContentsOfFile:[self.expirationsFile stringByAppendingString:EXPIRATION_HASH_FILE]];
        self.lastExpirationsFileDataDigest = (NSString *)[NSKeyedUnarchiver unarchiveObjectWithData:hashData];
        self.expirations = (NSMutableDictionary *)[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    else
    {
        self.expirations = [[NSMutableDictionary alloc] init];
    }
}

#define CLEANUP_INTERVAL 60 // Seconds
#define MAX_CACHE_IPHONE 8388608
#define MAX_CACHE_IPAD 33554432

#pragma mark - Timer

-(void)startCleanupTimer
{
    // Guard against being called outside of the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        self.cleanupTimer = [NSTimer scheduledTimerWithTimeInterval:CLEANUP_INTERVAL target:self selector:@selector(performCleanup:) userInfo:nil repeats:YES];
    });
}

-(void)performCleanup:(NSTimer *)timer
{
    NSLog(@"Current size: %d", self.folderSize);
    NSUInteger maxSize = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? MAX_CACHE_IPAD : MAX_CACHE_IPHONE);
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if(self.folderSize > maxSize)
    {
        NSLog(@"Max cache size passed! Cleaning up...");
        NSArray *files = [fileManager contentsOfDirectoryAtURL:[NSURL fileURLWithPath:[self folderPath]] includingPropertiesForKeys:@[NSURLCreationDateKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];
        NSMutableArray *sortedFileList = [[files sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
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
        }] mutableCopy];
        while(self.folderSize > maxSize)
        {
            NSURL *fileToDelete = [sortedFileList lastObject];
            [sortedFileList removeLastObject];
            NSLog(@"Deleting: %@", fileToDelete);
            NSDictionary *fileDictionary = [fileManager attributesOfItemAtPath:[fileToDelete path] error:nil];
            self.folderSize -= [fileDictionary fileSize];
            [fileManager removeItemAtURL:fileToDelete error:nil];
        }
    }
    // Write the expirations date dictionary to the file
    NSLog(@"Writing to expirations file: %@", self.expirationsFile);
    NSData *expirationsData = [NSKeyedArchiver archivedDataWithRootObject:self.expirations];
    NSString *expirationsDataDigest = [expirationsData md5];
    // Only write to file if it's new data
    if(![expirationsDataDigest isEqualToString:self.lastExpirationsFileDataDigest])
    {
        NSLog(@"Expirations data changed (%@ != %@)! Writing new file", self.lastExpirationsFileDataDigest, expirationsDataDigest);
        [fileManager createFileAtPath:self.expirationsFile contents:expirationsData attributes:nil];
        [fileManager createFileAtPath:[self.expirationsFile stringByAppendingString:EXPIRATION_HASH_FILE] contents:[NSKeyedArchiver archivedDataWithRootObject:expirationsDataDigest] attributes:nil];
        self.lastExpirationsFileDataDigest = expirationsDataDigest;
    }
}

#pragma mark - Push Data

-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier
{
    [self pushDataToCache:data identifier:identifier expiration:nil];
}

-(void)pushDataToCache:(NSData *)data identifier:(NSString *)identifier expiration:(NSDate *)expirationDate
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

    NSString *filePath = [folderPath stringByAppendingPathComponent:filename];
    if(![fileManager fileExistsAtPath:filePath])
    {
        [fileManager createFileAtPath:filePath contents:data attributes:nil];
        if(expirationDate)
        {
            NSLog(@"Expiring file at: %@ (%g)", filePath, [expirationDate timeIntervalSince1970]);
            self.expirations[filename] = @([expirationDate timeIntervalSince1970]);
        }
        self.folderSize += [data length];
    }
}

#pragma mark - Fetch Data

-(NSData *)fetchDataWithIdentifier:(NSString *)identifier
{
    NSUInteger old = CACurrentMediaTime();
    NSString *filename = [identifier md5];
    NSString *filePath = [[self folderPath] stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if([[self.expirations allKeys] containsObject:filename])
    {
        NSUInteger expirationDate = [self.expirations[filename] unsignedIntegerValue];
        if(expirationDate < [[NSDate date] timeIntervalSince1970])
        {
            NSLog(@"Cache for %@ has expired. Deleting.", identifier);
            [fileManager removeItemAtPath:filePath error:nil];
        }
    }
    NSData *data = [fileManager contentsAtPath:filePath];
    NSLog(@"%f", CACurrentMediaTime() - old);
    return data;
}

-(NSData *)fetchExpiringDataWithIdentifier:(NSString *)identifier
{
    NSUInteger old = CACurrentMediaTime();
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSArray *files = [fileManager contentsOfDirectoryAtPath:[self folderPath] error:nil];
    NSArray *filesWithSelectedPrefix = [files filteredArrayUsingPredicate: [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"self BEGINSWITH[cd] '%@_'", [identifier md5]]]];
    NSString *selectedFile = [filesWithSelectedPrefix lastObject];
    NSLog(@"Expiring: %g", CACurrentMediaTime() - old);
    return [fileManager contentsAtPath:[[self folderPath] stringByAppendingPathComponent:selectedFile]];
}

-(NSString *)folderPath
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]; // App's root folder
    return [documentsDirectory stringByAppendingPathComponent:@"FBFun"];
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
