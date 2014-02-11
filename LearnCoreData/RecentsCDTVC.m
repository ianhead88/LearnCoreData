//
//  RecentsCDTVC.m
//  LearnCoreData
//
//  Created by ian on 12/7/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "RecentsCDTVC.h"
#import "SharedDocumentHandler.h"
#import "Photo.h"

@interface RecentsCDTVC () <UISplitViewControllerDelegate>

@end

@implementation RecentsCDTVC

#define MAX_RECENT_PHOTOS 5

-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(void)setupFetchedResultsController
{
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.predicate = [NSPredicate predicateWithFormat:@"recentlyViewed != NULL"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"recentlyViewed.lastViewed" ascending:NO]];
        request.fetchLimit = MAX_RECENT_PHOTOS;
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    else {
        self.fetchedResultsController = nil;
    }
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flickr photo"];
    
    Photo *photo = [self photoForRowAtIndexPath:indexPath];
    
    cell.textLabel.text = [photo.title capitalizedString];
    cell.detailTextLabel.text = photo.photoDescription;
    cell.imageView.image = [UIImage imageWithData:photo.thumbData];
    
    
    if (!cell.imageView.image) {
        dispatch_queue_t fetchQ = dispatch_queue_create("ThumbFetch", NULL);
        dispatch_async(fetchQ, ^{
            //does not need to be done on the main thread because the URL Fetch has already happened
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:photo.photoURL_thumb]];
            //[NSThread sleepForTimeInterval:1.5];
            [photo.managedObjectContext performBlock:^{
                //this needs to be done on the main thread because managedObjectContext operate on the mainthread
                photo.thumbData = imageData;
                dispatch_async(dispatch_get_main_queue(), ^{
                    //need to wait for the main thread before redrawing the layouts
                    [cell setNeedsLayout]; // not sure if this is really necessary
                });
            }];
        });
        
    }
    
    return cell;
}

-(Photo *)photoForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext)
        self.managedObjectContext = [SharedDocumentHandler sharedManagedDocument].sharedDocument.managedObjectContext;
      [self setupFetchedResultsController];
    
}

- (void)sendDataForIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSURL *url;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            url = [NSURL URLWithString:photo.photoURL_phone];
            NSLog(@"iphone");
        }
        else {
            url = [NSURL URLWithString:photo.photoURL_ipad];
            NSLog(@"ipad");

        }
        
        [vc performSelector:@selector(setImageURL:) withObject:url];
                
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{                NSLog(@"prepare for segue top");

    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                NSLog(@"prepare for segue");
                [self sendDataForIndexPath:indexPath toViewController:segue.destinationViewController];
            }
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self sendDataForIndexPath:indexPath toViewController:[self.splitViewController.viewControllers lastObject]];
}

@end
