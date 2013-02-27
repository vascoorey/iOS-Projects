//
//  StanfordPhotosTVC.m
//  SPoT
//
//  Created by Vasco Orey on 2/25/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "StanfordTagsTVC.h"
#import "FlickrFetcher.h"
#import "Utils.h"

@interface StanfordTagsTVC ()
@property (nonatomic, strong) NSMutableSet *tags;
@property (nonatomic, strong) NSArray *finalTags;
@property (nonatomic, strong) NSMutableDictionary *tagOcurrences;
@end

@implementation StanfordTagsTVC

-(void)setup
{
    self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemFeatured tag:0];
}

-(void)awakeFromNib
{
    [self setup];
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
    {
        [self setup];
    }
    return self;
}

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
    self.tagOcurrences = nil;
    self.tags = nil;
    for(NSDictionary *photo in self.photos)
    {
        NSArray *separatedTags = [photo[FLICKR_TAGS] componentsSeparatedByString:@" "];
        for(NSString *tag in separatedTags)
        {
            if(![IGNORE_TAGS containsObject:tag])
            {
                NSString *capitalizedTag = [tag capitalizedString];
                if(![[self.tagOcurrences allKeys] containsObject:capitalizedTag])
                {
                    self.tagOcurrences[capitalizedTag] = @(1);
                }
                else
                {
                    int ocurrences = [self.tagOcurrences[capitalizedTag] intValue];
                    self.tagOcurrences[capitalizedTag] = @(ocurrences + 1);
                }
                [self.tags addObject:capitalizedTag];
            }
        }
    }
    self.finalTags = [self.tags allObjects];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self loadLatestPhotosFromFlickr];
    [self.refreshControl addTarget:self action:@selector(loadLatestPhotosFromFlickr) forControlEvents:UIControlEventValueChanged];
}

-(void)loadLatestPhotosFromFlickr
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t loadingQ = dispatch_queue_create("Loading Queue", NULL);
    dispatch_async(loadingQ, ^{
        NSArray *latestPhotos = [FlickrFetcher stanfordPhotos];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.photos = latestPhotos;
            [self.refreshControl endRefreshing];
        });
    });
}

-(NSArray *)photosForTag:(NSString *)tag
{
    NSAssert(self.finalTags, @"Must call getTagInfo before photosForTag:");
    NSMutableArray *photos = [[NSMutableArray alloc] initWithCapacity:[self.tagOcurrences[tag] intValue]];
    for(NSDictionary *photo in self.photos)
    {
        if([photo[FLICKR_TAGS] rangeOfString:[tag lowercaseString]].location != NSNotFound)
        {
            [photos addObject:photo];
        }
    }
    return photos;
}

-(NSString *)titleForRow:(NSUInteger)row
{
    return self.finalTags ? self.finalTags[row] : @"<null>";
}

-(NSString *)subtitleForRow:(NSUInteger)row
{
    return self.finalTags ? [NSString stringWithFormat:@"%@ photos", self.tagOcurrences[self.finalTags[row]]] : nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.tags count];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([sender isKindOfClass:[UITableViewCell class]])
    {
        if([segue.identifier isEqualToString:@"Show Photos For Tag"])
        {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            if ([segue.destinationViewController respondsToSelector:@selector(setPhotos:)]) {
                NSString *tag = [self titleForRow:indexPath.row];
                NSArray *photosForTag = [self photosForTag:tag];
                [segue.destinationViewController performSelector:@selector(setPhotos:) withObject:photosForTag];
                [segue.destinationViewController setTitle:tag];
            }
        }
    }
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
