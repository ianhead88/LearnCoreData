//
//  RecentPhotos+create.h
//  LearnCoreData
//
//  Created by ian on 12/8/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "RecentPhotos.h"
#import "Photo.h"

@interface RecentPhotos (create)

+(RecentPhotos *)recentPhotoWithPhoto:(Photo *)photo
               inManagedObjectContext:(NSManagedObjectContext *)context;

@end
