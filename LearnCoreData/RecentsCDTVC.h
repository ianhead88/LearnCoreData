//
//  RecentsCDTVC.h
//  LearnCoreData
//
//  Created by ian on 12/7/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "RecentPhotos.h"


@interface RecentsCDTVC : CoreDataTableViewController

@property (nonatomic, strong) RecentPhotos *recents;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

@end
