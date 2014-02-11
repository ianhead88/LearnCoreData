//
//  PhotosByTagCDTVC.m
//  LearnCoreData
//
//  Created by ian on 12/4/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "PhotosByTagCDTVC.h"
#import "Photo.h"
#import "RecentPhotos+create.h"


@interface PhotosByTagCDTVC ()

@end

@implementation PhotosByTagCDTVC

-(void)setTag:(Tags *)tag
{
    _tag = tag;
    [self setupFetchedResultsController];
    self.title = [tag.name capitalizedString];
}

-(void)setupFetchedResultsController
{
    if (self.tag.managedObjectContext) {
        NSLog(@"self.tag.managed object context");
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photo"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = [NSPredicate predicateWithFormat:@"%@ IN whatTags", self.tag];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.tag.managedObjectContext
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
    
    Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
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

- (void)sendDataForIndexPath:(NSIndexPath *)indexPath toViewController:(UIViewController *)vc
{
    if ([vc respondsToSelector:@selector(setImageURL:)]) {
        
        Photo *photo = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSURL *url;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            url = [NSURL URLWithString:photo.photoURL_phone];
        }
        else {
            url = [NSURL URLWithString:photo.photoURL_ipad];
        }
        
        [vc performSelector:@selector(setImageURL:) withObject:url];
        
        [RecentPhotos recentPhotoWithPhoto:photo inManagedObjectContext:photo.managedObjectContext];

    //    [vc setTitle:[self titleForRow:[url absoluteString]]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Image"]) {
                [self sendDataForIndexPath:indexPath toViewController:segue.destinationViewController];
            }
        }
    }
}


@end
