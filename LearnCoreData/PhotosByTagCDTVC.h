//
//  PhotosByTagCDTVC.h
//  LearnCoreData
//
//  Created by ian on 12/4/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Tags.h"

@interface PhotosByTagCDTVC : CoreDataTableViewController

@property (nonatomic, strong) Tags *tag;

@end
