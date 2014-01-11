//
//  ImageViewController.m
//  PhotoViewerBasic
//
//  Created by ian on 9/11/13.
//  Copyright (c) 2013 ian. All rights reserved.
//

#import "ImageViewController.h"
#import "AttributedStringViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleBarButtonItem;
@property (strong, nonatomic) UIPopoverController *urlPopover;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@end

@implementation ImageViewController

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]) {
        return (self.imageURL && !self.urlPopover.popoverVisible) ? YES : NO;
    } else {
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Show URL"]) {
        if ([segue.destinationViewController isKindOfClass:[AttributedStringViewController class]]) {
            AttributedStringViewController *asc = (AttributedStringViewController *)segue.destinationViewController;
            asc.text = [[NSAttributedString alloc] initWithString:[self.imageURL description]];
            if ([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
                self.urlPopover = ((UIStoryboardPopoverSegue *)segue).popoverController;
            }
        }
    }
}

-(void) awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(void) setTitle:(NSString *)title
{
    super.title = title;
    self.titleBarButtonItem.title = title;
}

-(void)setImageURL:(NSURL *)imageURL
{
    _imageURL = imageURL;
    [self resetImage];
}

-(void)writeCache:(NSData *)withData
{
        NSFileManager *fileManager = [[NSFileManager alloc] init];
        NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
        NSURL *url = [urls[0] URLByAppendingPathComponent:[self.imageURL lastPathComponent]];
    
        NSArray *files = [fileManager contentsOfDirectoryAtURL:urls[0]
                  includingPropertiesForKeys:nil
                                     options:NSDirectoryEnumerationSkipsHiddenFiles
                                       error:nil];

        BOOL matchingFile = FALSE;
        for (NSURL *file in files) {
        if ([[file absoluteString] isEqualToString:[url absoluteString]])
            matchingFile = TRUE;
        }
    
        if (!matchingFile)
            [withData writeToURL:url atomically:NO];
    
#pragma part of the code removes older files in the cache
    
        NSMutableDictionary *dateDict = [NSMutableDictionary dictionary];

        if ([files count] > 5) {

            for (NSURL *file in files) {
                NSDictionary *dateDictEntry = [file resourceValuesForKeys:@[NSURLContentAccessDateKey] error:nil];
                NSString *urlString = [file absoluteString];
                [dateDict setValue:urlString forKey:dateDictEntry[NSURLContentAccessDateKey]];
            }
            NSArray *dates = [dateDict allKeys];
            NSArray *sortedDates = [dates sortedArrayUsingSelector:@selector(compare:)];
            
            NSURL *lastURL = [[NSURL alloc] initWithString:dateDict[sortedDates[0]]];

            [fileManager removeItemAtURL:lastURL error:nil];            
        }
}

-(void) resetImage
{
    if (self.scrollView) {
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        NSURL *imageURL = self.imageURL; // local variable created to make sure flickerFetcher was not interrupted by the user (user clicked on another photo while waiting for image to load on a seperate queue)
        
        [self.spinner startAnimating];
        dispatch_queue_t imageFetchQ = dispatch_queue_create("image fetcher", NULL);
        dispatch_async(imageFetchQ, ^{
            
            [NSThread sleepForTimeInterval:1.0];
            //BEGIN READ Cache
            NSFileManager *fileManager = [[NSFileManager alloc] init];
            NSArray *urls = [fileManager URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask];
            NSArray *files = [fileManager contentsOfDirectoryAtURL:urls[0]
                                        includingPropertiesForKeys:nil
                                                           options:NSDirectoryEnumerationSkipsHiddenFiles
                                                             error:nil];
            NSURL *possibleCacheURL = self.imageURL;
            for (NSURL *file in files) {
                if ([[file lastPathComponent] isEqualToString:[self.imageURL lastPathComponent]]) {
                    possibleCacheURL = file;
                };
            }
            //END READ CACHE
            NSData *imageData = [[NSData alloc] initWithContentsOfURL:possibleCacheURL];
            UIImage *image =[[UIImage alloc] initWithData:imageData];
            if (self.imageURL == imageURL) {
                [self writeCache:imageData];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if (image) {
                        self.scrollView.zoomScale = 1.0;
                        self.scrollView.contentSize = image.size;
                        self.imageView.image = image;
                        self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                        
                        if (image.size.width >= image.size.height) {
                            
                            CGFloat zoomRatioNumerator = [self.scrollView superview].bounds.size.width;
                            CGFloat zoomRatioDenom = image.size.width;
                            CGFloat zoomRatio = zoomRatioNumerator / zoomRatioDenom;
                            
                            self.scrollView.zoomScale = zoomRatio;
                        }
                        if (image.size.width < image.size.height) {
                            
                            CGFloat zoomRatioNumerator = [self.scrollView superview].bounds.size.height;
                            CGFloat zoomRatioDenom = image.size.height;
                            CGFloat zoomRatio = zoomRatioNumerator / zoomRatioDenom;
                            
                            self.scrollView.zoomScale = zoomRatio;
                        }
                    }
                    [self.spinner stopAnimating];
                });
            }
        });

    }
}

- (UIImageView *) imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    return _imageView;
}

- (UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.2;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self; 
    [self resetImage];
    self.titleBarButtonItem.title = self.title;
}

- (void)viewDidLayoutSubviews
{
    [self resetImage]; // needed to change the layout when the phone is flipped
}


@end
