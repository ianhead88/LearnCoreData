//
//  Photo+flickr.m
//  LearnCoreData
//
//  Created by ian on 11/24/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "Photo+flickr.h"
#import "FlickrFetcher.h"
#import "Tags+flickr.h"

@implementation Photo (flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context
{
    Photo *photo = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES]];
    request.predicate = [NSPredicate predicateWithFormat:@"uniqueID = %@", [photoDictionary[FLICKR_PHOTO_ID] description]];
    
    NSError *error = nil;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || [matches count] > 1 || error) {
        NSLog(@"Error in photoWithFlickrInfo: %@, %@", error, matches);
    } else if (![matches count]) {
        photo = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:context];
        
        photo.title = [photoDictionary[FLICKR_PHOTO_TITLE] description];
        photo.photoDescription = [[photoDictionary valueForKeyPath:FLICKR_PHOTO_DESCRIPTION] description];
        photo.photoURL_phone = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatLarge] absoluteString];
        photo.photoURL_ipad = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatOriginal] absoluteString];
        photo.photoURL_thumb = [[FlickrFetcher urlForPhoto:photoDictionary format:FlickrPhotoFormatSquare] absoluteString];
        photo.uniqueID = [photoDictionary[FLICKR_PHOTO_ID] description];
        photo.whatTags = [Tags TagsFromFlickr:photoDictionary inManagedObjectContext:context];
        
    } else {
        photo = [matches lastObject]; //there's already a photo in the dictionary, no need to recreate it
    }
  
    return photo;
}

@end
