//
//  Photo+Flickr.m
//  CoreData-SPoT
//
//  Created by Vasco Orey on 3/11/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Tag+Create.h"
#import "Utils.h"

@implementation Photo (Flickr)

+(Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
       inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if(!matches || [matches count] > 1)
    {
        // Handle error
    }
    else if(![matches count])
    {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.subtitle = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.imageURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.unique = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.thumbnailURL = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.lastAccessDate = [NSDate date];
        
        NSArray *allTags = [photoDictionary[FLICKR_TAGS] componentsSeparatedByString:@" "];
        for(NSString *tagName in allTags)
        {
            if(![IGNORE_TAGS containsObject:tagName])
            {
                // For each tagName that we're not ignoring add the appropriate nsmanagedobject (Tag)
                Tag *tag = [Tag tagWithName:tagName inManagedObjectContext:context];
                [photo addTagsObject:tag];
            }
        }
    }
    else
    {
        photo = [matches lastObject];
        photo.lastAccessDate = [NSDate date];
    }
    
    return photo;
}

@end
