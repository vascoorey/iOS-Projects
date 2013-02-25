//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Vasco Orey on 2/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//
//  Will call setTag: as part of any "Show Tag" segue

#import "StanfordTagsTVC.h"
#import "FlickrFetcher.h"

@interface StanfordTagsTVC ()
@property (nonatomic, strong) NSMutableSet *tags;
@property (nonatomic, strong) NSArray *finalTags;
@property (nonatomic, strong) NSMutableDictionary *tagOcurrences;
@end

@implementation StanfordTagsTVC

-(NSMutableSet *)tags
{
    if(!_tags)
    {
        _tags = [[NSMutableSet alloc] init];
    }
    return _tags;
}

-(NSMutableDictionary *)tagOcurrences
{
    if(!_tagOcurrences)
    {
        _tagOcurrences = [[NSMutableDictionary alloc] init];
    }
    return _tagOcurrences;
}

-(void)setPhotos:(NSArray *)photos
{
    _photos = photos;
    [self getTagInfo];
    [self.tableView reloadData];
}

-(void)getTagInfo
{
    for(NSDictionary *photo in self.photos)
    {
        NSArray *separatedTags = [photo[FLICKR_TAGS] componentsSeparatedByString:@" "];
        for(NSString *tag in separatedTags)
        {
            if(![[self.tagOcurrences allKeys] containsObject:tag])
            {
                self.tagOcurrences[tag] = @(1);
            }
            else
            {
                int ocurrences = [self.tagOcurrences[tag] intValue];
                self.tagOcurrences[tag] = @(ocurrences + 1);
            }
            [self.tags addObject:tag];
        }
    }
    self.finalTags = [self.tags allObjects];
    NSLog(@"Tags: %@", self.finalTags);
    NSLog(@"Ocurrences: %@", self.tagOcurrences);
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.photos = [FlickrFetcher stanfordPhotos];
}

-(NSString *)titleForRow:(NSUInteger)row
{
    return self.finalTags ? self.finalTags[row] : @"<null>";
}

-(NSString *)subtitleForRow:(NSUInteger)row
{
    return self.finalTags ? [self.tagOcurrences[self.finalTags[row]] description] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSAssert(false, @"haha");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Flickr Tag";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    cell.textLabel.text = [self titleForRow:indexPath.row];
    cell.detailTextLabel.text = [self subtitleForRow:indexPath.row];
    
    return cell;
}

@end
