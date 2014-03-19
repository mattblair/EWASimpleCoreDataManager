//
//  GeoDataManager.m
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/19/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import "GeoDataManager.h"
#import "NSManagedObject+EWAUtilities.h"

@implementation GeoDataManager

#pragma mark - Configuration Overrides

- (NSString *)modelFilename {
    
    return @"places";
}

- (NSString *)databaseFilenameInBundle {
    
    //return @"demo.sqlite";
    return nil;
}

// if nil, read datastore from bundle, without saving
- (NSString *)databaseFilenameOnDisk {
    
    return @"geo-db.sqlite";
}

- (BOOL)replaceDatabase {
    
    return NO;
}


#pragma mark - Convenience Methods

- (void)populateIfEmpty {
    
    NSManagedObjectContext *moc = [self mainThreadMOC];
    
    NSFetchRequest *placeCountRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *placeEntity = [NSEntityDescription entityForName:@"Place"
                                                   inManagedObjectContext:moc];
    
    [placeCountRequest setEntity:placeEntity];
    
    NSError *error = nil;
    NSUInteger placeCount = [moc countForFetchRequest:placeCountRequest
                                                error:&error];
    
    // NSNotFound is returned if there is an error
    if (placeCount == NSNotFound || placeCount == 0) {
        
        NSLog(@"No Places found. Loading data from JSON files.");
        
        [self loadGeoJSON];
    }
}

- (BOOL)loadGeoJSON {
    
    BOOL result = YES;
    
    // not required, but it makes lines a little shorter
    NSManagedObjectContext *moc = [self mainThreadMOC];
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:@"places140316"
                                                         ofType:@"json"];
	
	NSError *fileLoadError = nil;
    NSData *placeJSONData = [NSData dataWithContentsOfFile:filepath
                                                   options:NSDataReadingUncached
                                                     error:&fileLoadError];
    
    if (!placeJSONData) {
        NSLog(@"Loading JSON File Failed: %@, %@", fileLoadError, [fileLoadError userInfo]);
        return NO;
    }
    
    NSError *jsonDeserializeError = nil;
    
    // this was the JSONKit code
    //NSArray *composerArray = [composerJSONData objectFromJSONDataWithParseOptions:JKParseOptionStrict
    //                                                                        error:&jsonDeserializeError];
    
    NSDictionary *collection = [NSJSONSerialization JSONObjectWithData:placeJSONData
                                                               options:0
                                                                 error:&jsonDeserializeError];
    
    if (!collection || ![collection isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Deserializing JSON Data Failed: %@, %@", jsonDeserializeError, [jsonDeserializeError userInfo]);
        return NO;
    }
    
    NSArray *placeArray = [self extractFeaturesFromGeoJSONFeatureCollection:collection];
    
    if (!placeArray || ![placeArray isKindOfClass:[NSArray class]]) {
        NSLog(@"Feature retrieval Failed.");
        return NO;
    }
    
    // could switch this to an NSManagedObject subclass...
    NSManagedObject *aPlace = nil;
    NSError *mocError = nil;
    
    for (NSDictionary *geoJSONDict in placeArray) {
        
        aPlace = [NSEntityDescription insertNewObjectForEntityForName:@"Place"
                                               inManagedObjectContext:moc];
        
        NSDictionary *flatDictionary = [self flattenedGeoJSONFeature:geoJSONDict];
        
        //NSLog(@"Flattened version: %@", flatDictionary);
        
        [aPlace setValuesFromJSONDictionary:flatDictionary
                          withDateFormatter:[self iso8601DateFormatter]
                        excludingProperties:@[@"fieldToIgnore"]];
        
        if (![moc save:&mocError]) {
            
            NSLog(@"Error saving fragments from JSON - error:%@", mocError);
            result = NO;
        }
        
        aPlace = nil;
    }
    
    return result;
}

@end
