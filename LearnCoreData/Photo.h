//
//  Photo.h
//  LearnCoreData
//
//  Created by ian on 11/28/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class RecentPhotos, Tags;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoDescription;
@property (nonatomic, retain) NSString * photoURL_ipad;
@property (nonatomic, retain) NSString * photoURL_phone;
@property (nonatomic, retain) NSString * photoURL_thumb;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * uniqueID;
@property (nonatomic, retain) NSData * thumbData;
@property (nonatomic, retain) RecentPhotos *recentlyViewed;
@property (nonatomic, retain) NSSet *whatTags;
@end

@interface Photo (CoreDataGeneratedAccessors)

- (void)addWhatTagsObject:(Tags *)value;
- (void)removeWhatTagsObject:(Tags *)value;
- (void)addWhatTags:(NSSet *)values;
- (void)removeWhatTags:(NSSet *)values;

@end
