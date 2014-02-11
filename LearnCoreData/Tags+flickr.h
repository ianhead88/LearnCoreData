//
//  Tags+flickr.h
//  LearnCoreData
//
//  Created by ian on 11/27/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "Tags.h"

@interface Tags (flickr)

+(NSSet *)TagsFromFlickr:(NSDictionary *)photoDictionary
 inManagedObjectContext:(NSManagedObjectContext *)context;


@end
