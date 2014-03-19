//
//  DemoDataManager.m
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import "DemoDataManager.h"
#import "NSManagedObject+EWAUtilities.h"

@implementation DemoDataManager


#pragma mark - Configuration Overrides

- (NSString *)modelFilename {
    
    return @"demo";
}

- (NSString *)databaseFilenameInBundle {
    
    //return @"demo.sqlite";
    return nil;
}

// if nil, read datastore from bundle, without saving
- (NSString *)databaseFilenameOnDisk {
    
    return @"demo-db.sqlite";
}

- (BOOL)replaceDatabase {
    
    return NO;
}


#pragma mark - Convenience Methods

- (void)populateIfEmpty {
    
    NSManagedObjectContext *moc = [self mainThreadMOC];
    
    NSFetchRequest *composerCountRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *composerEntity = [NSEntityDescription entityForName:@"Composer"
                                                      inManagedObjectContext:moc];
    
    [composerCountRequest setEntity:composerEntity];
    
    NSError *error = nil;
    NSUInteger composerCount = [moc countForFetchRequest:composerCountRequest
                                                   error:&error];
    
    //DLog(@"There are %d makers in the datastore.", composerCount);
    
    // NSNotFound is returned if there is an error
    if (composerCount == NSNotFound || composerCount == 0) {
        
        //DLog(@"No Composers found. Loading data from JSON files.");
        
        [self loadComposersFromJSON];
    }
}

- (BOOL)loadComposersFromJSON {
    
    BOOL result = YES;
    
    // not required, but it makes lines a little shorter
    NSManagedObjectContext *moc = [self mainThreadMOC];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"composers"
                                                         ofType:@"json"];
	
	NSError *fileLoadError = nil;
    NSData *composerJSONData = [NSData dataWithContentsOfFile:filepath
                                                      options:NSDataReadingUncached
                                                        error:&fileLoadError];
    
    if (!composerJSONData) {
        NSLog(@"Loading JSON File Failed: %@, %@", fileLoadError, [fileLoadError userInfo]);
        return NO;
    }
    
    NSError *jsonDeserializeError = nil;
    
    // this was the JSONKit code
    //NSArray *composerArray = [composerJSONData objectFromJSONDataWithParseOptions:JKParseOptionStrict
    //                                                                        error:&jsonDeserializeError];
    
    NSArray *composerArray = [NSJSONSerialization JSONObjectWithData:composerJSONData
                                                             options:0
                                                               error:&jsonDeserializeError];
    
    if (!composerArray || ![composerArray isKindOfClass:[NSArray class]]) {
        NSLog(@"Deserializing JSON Data Failed: %@, %@", jsonDeserializeError, [jsonDeserializeError userInfo]);
        return NO;
    }
        
    // switch this to an NSManagedObject subclass...
    NSManagedObject *aComposer = nil;
    NSError *mocError = nil;
    
    for (NSDictionary *composerDict in composerArray) {
        
        //newMaker = (BoxMaker *)[NSEntityDescription insertNewObjectForEntityForName:@"BoxMaker"
        //                                                     inManagedObjectContext:moc];
        
        aComposer = [NSEntityDescription insertNewObjectForEntityForName:@"Composer"
                                                  inManagedObjectContext:moc];
        
        [aComposer setValuesFromJSONDictionary:composerDict
                             withDateFormatter:[self iso8601DateFormatter]];
        
        if (![moc save:&mocError]) {
            
            NSLog(@"Error saving fragments from JSON - error:%@", mocError);
            result = NO;
        }
        
        aComposer = nil;
    }
    
    return result;
}

@end
