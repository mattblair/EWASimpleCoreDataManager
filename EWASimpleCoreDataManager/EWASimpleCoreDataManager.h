//
//  EWASimpleCoreDataManager.h
//
//  Created by Matt Blair on 1/10/14.
//  Copyright (c) 2014 Elsewise LLC. MIT License.
//

// Add this into a project that didn't use the Core Data templates, or delete
// all the boilerplate in the app delegate

// inspired by: https://gist.github.com/922496
// via: http://nachbaur.com/blog/smarter-core-data

// NOTE: This is primarily intended for reading at this point, and does not yet
// implement parent/child MOCs.

// TIPS:
// * have app state notifications call save
// *

// TODO: implement parent/child MOCs
// TODO: implement workingMOC to always return a background thread

extern NSString * const EWASimpleCoreDataManagerDidSaveNotification;
extern NSString * const EWASimpleCoreDataManagerDidSaveFailedNotification;

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface EWASimpleCoreDataManager : NSObject

+ (instancetype)sharedInstance;

// looks for the database, and copies from bundle if needed
- (BOOL)confirmDatabaseInstalled;

// save any changes on the mainThreadMOC
// workingMOC's should handle their own saves
- (BOOL)save;

// for UIKit-related use
- (NSManagedObjectContext *)mainThreadMOC;

// May not be on the main thread. Use for background work.
- (NSManagedObjectContext *)workingMOC;


// Data Import Utilities

// a reusable date formatter for importing from JSON with ISO8601 date strings
- (NSDateFormatter *)iso8601DateFormatter;

- (NSArray *)extractFeaturesFromGeoJSONFeatureCollection:(NSDictionary *)collection;
- (NSDictionary *)flattenedGeoJSONFeature:(NSDictionary *)feature;

@end
