//
//  DataModel.m
//  Checklists
//
//  Created by Vasco Orey on 1/26/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DataModel.h"

@implementation DataModel

-(NSMutableArray *)lists
{
    if(!_lists)
    {
        _lists = [[NSMutableArray alloc] init];
    }
    return _lists;
}

-(id)init
{
    if((self = [super init]))
    {
        [self loadChecklists];
        [self registerDefaults];
    }
    return self;
}

#pragma mark defaults

-(void)registerDefaults
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:-2], @"ChecklistIndex", nil];
    [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
}

-(int)indexOfSelectedChecklist
{
    return [[NSUserDefaults standardUserDefaults] integerForKey:@"ChecklistIndex"];
}

-(void)setIndexOfSelectedChecklist:(int)index
{
    [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"ChecklistIndex"];
}

#pragma mark File IO

-(NSString *)documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

-(NSString *)dataFilePath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"Checklists.plist"];
}

-(void)saveChecklists
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self.lists forKey:@"Checklists"];
    [archiver finishEncoding];
    [data writeToFile:[self dataFilePath] atomically:YES];
}

-(void)loadChecklists
{
    NSString *path = [self dataFilePath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        self.lists = [unarchiver decodeObjectForKey:@"Checklists"];
        [unarchiver finishDecoding];
    }
}

@end
