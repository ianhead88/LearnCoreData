//
//  Tags+flickr.m
//  LearnCoreData
//
//  Created by ian on 11/27/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "Tags+flickr.h"
#import "FlickrFetcher.h"


@implementation Tags (flickr)

+(NSSet *)TagsFromFlickr:(NSDictionary *)photoDictionary
  inManagedObjectContext:(NSManagedObjectContext *)context
{
    NSSet *tags = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tags"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]];
    NSError *error;
    
    Tags *tag;
        
    NSString *tagList = photoDictionary[FLICKR_TAGS];
    NSArray *tagArray = [tagList componentsSeparatedByString:@" "];
    if (![tagArray count]) return nil;
    NSMutableSet *filterTags = [NSMutableSet set];
    for (NSString *tagString in tagArray) {
        if ([tagString isEqualToString:@"cs193pspot"]) continue;
        if ([tagString isEqualToString:@"portrait"]) continue;
        if ([tagString isEqualToString:@"landscape"]) continue;
        
        error = nil;
        tag = nil;
        
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", tagString];
        NSArray *matches = [context executeFetchRequest:request error:&error];
        
        if (!matches || [matches count]>1 || error) {
            NSLog(@"Error in TagsFromFlickr: %@, %@", error, matches);
        }
        else if (![matches count]) {
            
            tag = [NSEntityDescription insertNewObjectForEntityForName:@"Tags" inManagedObjectContext:context];
            tag.name = tagString;
        }
        else
            tag = [matches lastObject];

        if (tag) [filterTags addObject:tag];

        [filterTags addObject:tag];
    }
    
    tags = filterTags;
    return tags;
}

@end
