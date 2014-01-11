//
//  Thumb.h
//  LearnCoreData
//
//  Created by ian on 11/24/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;

@interface Thumb : NSManagedObject

@property (nonatomic, retain) NSData * thumbData;
@property (nonatomic, retain) Photo *newRelationship;

@end
