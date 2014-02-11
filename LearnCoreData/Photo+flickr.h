//
//  Photo+flickr.h
//  LearnCoreData
//
//  Created by ian on 11/24/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "Photo.h"

@interface Photo (flickr)

+ (Photo *)photoWithFlickrInfo:(NSDictionary *)photoDictionary
        inManagedObjectContext:(NSManagedObjectContext *)context;

@end
