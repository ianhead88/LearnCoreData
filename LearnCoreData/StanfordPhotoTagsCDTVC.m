//
//  StanfordPhotoTagsCDTVC.m
//  LearnCoreData
//
//  Created by ian on 11/28/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "StanfordPhotoTagsCDTVC.h"
#import "Tags.h"
#import "FlickrFetcher.h"
#import "Photo+flickr.h"
#import "SharedDocumentHandler.h"

@interface StanfordPhotoTagsCDTVC () <UISplitViewControllerDelegate>

@end

@implementation StanfordPhotoTagsCDTVC

#pragma mark - UISplitViewControllerDelegate

-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation
{
    return NO;
}


- (void)setManagedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    _managedObjectContext = managedObjectContext;
    if (managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tags"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                  ascending:YES
                                                                   selector:@selector(localizedCaseInsensitiveCompare:)]];
        
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    } else {
        self.fetchedResultsController = nil;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Show Photos"]) {
                if ([segue.destinationViewController respondsToSelector:@selector(setTag:)]) {
                    Tags *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
                    [segue.destinationViewController performSelector:@selector(setTag:)
                                                          withObject:tag];
                }
            }
        }
    }
}

-(void)setupFetchedResultsController
{

    
    if (self.managedObjectContext) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tags"];
        request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)]];
        request.predicate = nil;
        self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                            managedObjectContext:self.managedObjectContext
                                                                              sectionNameKeyPath:nil
                                                                                       cacheName:nil];
    }
    
    else 
        self.fetchedResultsController = nil;

}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"flickr tag" forIndexPath:indexPath];
    
    Tags *tag = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    int photoCount = [tag.photo count];
    
    cell.textLabel.text = [tag.name capitalizedString];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d photo%@", photoCount, photoCount > 1 ? @"s" : @""];
    
    return cell;
}

#pragma BEGIN SET DATA

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.managedObjectContext) {
        [self usePhotoDocument];
        
        // perform the fetch again (in case we deleted any photos)
        [self performFetch];

    }
}

-(void)usePhotoDocument
{
    
    SharedDocumentHandler *dataHelper = [SharedDocumentHandler sharedManagedDocument];
    UIManagedDocument *document = dataHelper.sharedDocument;
    NSURL *url = document.fileURL;
        
    if (![[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
        //create it
        [document saveToURL:url
           forSaveOperation:UIDocumentSaveForCreating
          completionHandler:^(BOOL success) {
              if (success) {
                  self.managedObjectContext = document.managedObjectContext;
                  [self refresh];
              }
          }];
    } else if (document.documentState == UIDocumentStateClosed) {
        //open it
        [document openWithCompletionHandler:^(BOOL success){
            if (success) {
                self.managedObjectContext = document.managedObjectContext;
                [self refresh];
            }
        }];
    } else {
        //try to use it (if it's already open)
        self.managedObjectContext = document.managedObjectContext;
    }
    
}

-(IBAction)refresh
{
    [self.refreshControl beginRefreshing];
    dispatch_queue_t fetchQ = dispatch_queue_create("Flickr Fetch", NULL);
    dispatch_async(fetchQ, ^{
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        NSArray *photos = [FlickrFetcher stanfordPhotos];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        //put the photos in Core Data
        [self.managedObjectContext performBlock:^{  //needed to ensure we access the database on the main thread
            for (NSDictionary *photo in photos) {
                [Photo photoWithFlickrInfo:photo inManagedObjectContext:self.managedObjectContext];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.refreshControl endRefreshing];
            });
        }];
    });
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
}

#pragma END SET DATA


@end
