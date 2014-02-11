//
//  RecentPhotos+create.m
//  LearnCoreData
//
//  Created by ian on 12/8/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "RecentPhotos+create.h"

@implementation RecentPhotos (create)

+(RecentPhotos *)recentPhotoWithPhoto:(Photo *)photo
inManagedObjectContext:(NSManagedObjectContext *)context

{
    RecentPhotos *rp = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"RecentPhotos"];
    request.predicate = [NSPredicate predicateWithFormat:@"photo = %@", photo];
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    
    
    if (!matches) {
        //handle error
    }
    else if (![matches count]) {
        //insert object for entity
        rp = [NSEntityDescription insertNewObjectForEntityForName:@"RecentPhotos" inManagedObjectContext:context];
        rp.photo = photo;
        rp.lastViewed = [NSDate date];
        
        request.predicate = nil; //returns all photos
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"lastViewed" ascending:NO]];
        matches = [photo.managedObjectContext executeFetchRequest:request error:&error];

        [context save:&error];
        
        if ([matches count] > 10) {
            [context deleteObject:[matches lastObject]];
        }
        
    }
    else
        //if a photo already exists, then just update it's time, and set it as recent
        rp = [matches lastObject];
        rp.lastViewed = [NSDate date];
    
    
    return rp;
}

@end
