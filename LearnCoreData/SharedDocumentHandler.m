//
//  SharedDocumentHandler.m
//  LearnCoreData
//
//  Created by ian on 1/7/14.
//  Copyright (c) 2014 ian. All rights reserved.
//

#import "SharedDocumentHandler.h"

@interface SharedDocumentHandler ()

@end

@implementation SharedDocumentHandler

-(UIManagedDocument *)sharedDocument
{
    if (!_sharedDocument) {
        NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                             inDomains:NSUserDomainMask] lastObject];
        url = [url URLByAppendingPathComponent:@"Photo_Document"];
        _sharedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
    }
    return _sharedDocument;
}

+(SharedDocumentHandler *)sharedManagedDocument
{
    static dispatch_once_t pred = 0;
    static id _sharedInstance;
    
    dispatch_once(&pred, ^{    //need to understand why an "&" is required here
    
        _sharedInstance = [[self alloc] init];
    });
    
    return _sharedInstance;
}

-(void)saveDocument
{
    [self.sharedDocument saveToURL:self.sharedDocument.fileURL
            forSaveOperation:UIDocumentSaveForOverwriting
           completionHandler:NULL];
}


@end
