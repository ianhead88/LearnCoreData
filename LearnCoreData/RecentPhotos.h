//
//  RecentPhotos.h
//  LearnCoreData
//
//  Created by ian on 11/28/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface RecentPhotos : NSManagedObject

@property (nonatomic, retain) NSDate * lastViewed;
@property (nonatomic, retain) Photo *photo;

@end
