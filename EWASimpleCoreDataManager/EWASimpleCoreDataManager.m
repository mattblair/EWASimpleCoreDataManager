//
//  EWASimpleCoreDataManager.m
//
//  Created by Matt Blair on 1/10/14.
//  Copyright (c) 2014 Elsewise LLC. MIT License.
//

// DLog from Marcus Zarra, as defined here:
// http://www.cimgf.com/2010/05/02/my-current-prefix-pch-file/
// and
// https://github.com/ZarraStudios/ZDS_Shared

#ifndef DLog
#ifdef DEBUG
#define DLog(...) NSLog(@"%s(%p) %@", __PRETTY_FUNCTION__, self, [NSString stringWithFormat:__VA_ARGS__])
#else
#define DLog(...) do { } while (0)
#endif
#endif

// ISO 8601, as described here: http://www.w3.org/TR/NOTE-datetime
#define ISO_8601_DATE_FORMAT @"yyyy-MM-dd'T'HH:mm:ssZ"

// GeoJSON Feature object specification:
// http://geojson.org/geojson-spec.html#feature-objects
#define kGeoJSONGeometryKey @"geometry"
#define kGeoJSONCoordinatesKey @"coordinates"
#define kGeoJSONTypeKey @"type"
#define kGeoJSONFeatureValue @"Feature"
#define kGeoJSONPointValue @"Point"
#define kGeoJSONIDKey @"id"
#define kGeoJSONPropertiesKey @"properties"

#import "EWASimpleCoreDataManager.h"

// deprecate?
NSString * const EWASimpleCoreDataManagerDidSaveNotification = @"EWASimpleCoreDataManagerDidSaveNotification";
NSString * const EWASimpleCoreDataManagerDidSaveFailedNotification = @"EWASimpleCoreDataManagerDidSaveFailedNotification";

@interface EWASimpleCoreDataManager ()

@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSManagedObjectContext *mainThreadManagedObjectContext;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end


@implementation EWASimpleCoreDataManager


#pragma mark - Setup

// adapted from:
// http://nshipster.com/c-storage-classes/
+ (instancetype)sharedInstance {
    static id _sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        if ([[self class] isKindOfClass:[EWASimpleCoreDataManager class]]) {
            NSLog(@"WARNING: The EWASimpleCoreDataManager class is intended for subclassing."
                  @"Direct use of its sharedInstance method is not recommended. "
                  @"And probably won't do what you want anyway.");
        }
        
        // message to class added, for subclassing support
        _sharedInstance = [[[self class] alloc] init];
    });
    
    return _sharedInstance;
}

- (void)dealloc {
	[self save];
}


#pragma mark - Default Configuration (override in a subclass)

- (NSString *)modelFilename {
    
    return @"model";
}

// extension should be included here, e.g. <myApp><YYMMDD>.sqlite
// TODO: if nil, a new datastore will be created
- (NSString *)databaseFilenameInBundle {
    
    return nil;
}

// TODO: if nil, read datastore from bundle, without saving
- (NSString *)databaseFilenameOnDisk {
    
    return nil;
}

// If nil, database stored in /Documents directory
// TODO: Needs testing!
- (NSString *)librarySubdirectoryForDatastore {
    
    return nil;
}

// TODO: YES value is untested
- (BOOL)blockDatabaseFromiCloudBackup {
    
    return NO;
}

// Typical Use:
// NO when shipping app store releases
// YES while testing and sending beta builds with refreshed data
- (BOOL)replaceDatabase {
    
    return NO;
}


#pragma mark - Core Data Stack

// adapted from the boilerplate in Apple's Core Data templates

- (NSManagedObjectModel*)managedObjectModel {
	
    if (_managedObjectModel)
		return _managedObjectModel;
    
	NSString *modelPath = [[NSBundle mainBundle] pathForResource:[self modelFilename]
                                                          ofType:@"momd"];
    
	_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:[NSURL fileURLWithPath:modelPath]];
    
	return _managedObjectModel;
}

// renaming of mainObjectContext here: https://gist.github.com/922496
- (NSManagedObjectContext*)mainThreadManagedObjectContext {
	
    if (_mainThreadManagedObjectContext)
		return _mainThreadManagedObjectContext;
    
	// Create the main context only on the main thread
	if (![NSThread isMainThread]) {
		[self performSelectorOnMainThread:@selector(mainThreadManagedObjectContext)
                               withObject:nil
                            waitUntilDone:YES];
		return _mainThreadManagedObjectContext;
	}
    
	_mainThreadManagedObjectContext = [[NSManagedObjectContext alloc] init];
	[_mainThreadManagedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    
	return _mainThreadManagedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self databaseDirectoryURL] URLByAppendingPathComponent:[self databaseFilenameOnDisk]];
    
    DLog(@"Datastore URL on disk is: %@", storeURL);
    
    // options for version migration
    // via: https://gist.github.com/922496
    
    //NSDictionary *options = @{ NSMigratePersistentStoresAutomaticallyOption : [NSNumber numberWithBool:YES],
    //                           NSInferMappingModelAutomaticallyOption : [NSNumber numberWithBool:YES] };
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                                   configuration:nil
                                                             URL:storeURL
                                                         options:nil
                                                           error:&error]) {
        
        DLog(@"Unresolved error %@, %@", error, [error userInfo]);
        //abort();
    }
    
    return _persistentStoreCoordinator;
}


#pragma mark - File System Utilities

// Defaults to app's /Documents directory
// If file sharing with iTunes is enabled, keep the data store hidden by using
// a sub-directory of Library that is specific to the app.
// Do not use /Library/Caches
- (NSURL *)databaseDirectoryURL {
    
    NSURL *directoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                  inDomains:NSUserDomainMask] lastObject];
    
    // NOTE: library storage has not been tested
    if ([self librarySubdirectoryForDatastore]) {
        
        NSURL *libraryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory
                                                                    inDomains:NSUserDomainMask] lastObject];
        
        //use path because absoluteString prepends file://localhost which borks the createDirectory... method
        NSString *libraryPathString = [libraryURL path];
        
        NSString *datastorePathString = [libraryPathString stringByAppendingPathComponent:[self librarySubdirectoryForDatastore]];
        
        DLog(@"Datastore directory will be: %@", datastorePathString);
        
        BOOL isDir;
        BOOL dirIsThere = [[NSFileManager defaultManager] fileExistsAtPath:datastorePathString
                                                               isDirectory:&isDir];
        
        // create the directory if it doesn't exist
        if (!(dirIsThere && isDir)) {
            
            DLog(@"Datastore directory not found. Creating it...");
            
            // if file protection is needed:
            //NSDictionary *attr = @{ NSFileProtectionKey : NSFileProtectionComplete };
            
            NSError *error = nil;
            BOOL createdDirectory = [[NSFileManager defaultManager] createDirectoryAtPath:datastorePathString
                                                              withIntermediateDirectories:YES
                                                                               attributes:nil
                                                                                    error:&error];
            if (createdDirectory) {
                
                DLog(@"Created datastore directory at: %@", datastorePathString);
            }
            else {
                
                DLog(@"FAILED to create datastore directory at: %@", datastorePathString);
                DLog(@"Error was %@ -- %@", [error description], [error userInfo]);
                DLog(@"Will use app's documents directory.");
            }
        }
        
        directoryURL = [NSURL fileURLWithPath:datastorePathString
                                  isDirectory:YES];
    }
    
    return directoryURL;
}


#pragma mark - Public API

// looks for the database, and copies it from the bundle if needed
- (BOOL)confirmDatabaseInstalled {
    
    NSString *storePath = [[[self databaseDirectoryURL] path] stringByAppendingPathComponent:[self databaseFilenameOnDisk]];
    
    DLog(@"The storePath is: %@", [storePath description]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([self replaceDatabase]) {
        
        // remove any existing copy of the database, to force a reinstall
        if ([fileManager fileExistsAtPath:storePath]) {
            
            NSError *databaseDeleteError;
            
            BOOL deleteSuccess = [fileManager removeItemAtPath:storePath
                                                         error:&databaseDeleteError];
            
            NSString *deletionDetails = deleteSuccess ?
                @"Succeeded." :
                [NSString stringWithFormat:@"Failed with error %@", databaseDeleteError];
            
            DLog(@"Deletion of existing database: %@", deletionDetails);
        }
    }
    
    if (![fileManager fileExistsAtPath:storePath]) {
        
        DLog(@"No database found in app's Documents directory...");
        
        NSString *databaseFromBundle = [[NSBundle mainBundle] pathForResource:[self databaseFilenameInBundle]
                                                                       ofType:nil];
        
        DLog(@"The location of the database in the bundle is: %@", [databaseFromBundle description]);
        
        if (databaseFromBundle) {
            
            NSError *copyError = nil;
            
            [fileManager copyItemAtPath:databaseFromBundle toPath:storePath error:&copyError];
            
            if ([self blockDatabaseFromiCloudBackup]) {
                
                // based on: https://gist.github.com/tibr/1999985
                // NOTE: This does not handle the com.apple.MobileBackup approach
                // required before iOS 5.1
                // NOTE: This has not been fully tested yet
                
                NSURL *databaseURL = [NSURL URLWithString:storePath];
                
                NSError *iCloudError = nil;
                BOOL iCloudBlocked = [databaseURL setResourceValue:[NSNumber numberWithBool:YES]
                                                            forKey:NSURLIsExcludedFromBackupKey
                                                             error:&iCloudError];
                
                if (!iCloudBlocked) {
                    DLog(@"WARNING: Blocking iCloud backup of database failed: %@", iCloudError);
                }
            }
        } else {
            
            DLog(@"No database found in bundle path.");
            return NO;
        }
    } else {
        
        DLog(@"Database already exists.");
    }
    
    return YES;
}

- (BOOL)save {
    
    BOOL returnValue = NO;
    
    NSError *error = nil;
    NSManagedObjectContext *mainMOC = self.mainThreadManagedObjectContext;
    
    if (mainMOC) {
        if ([mainMOC hasChanges] && ![mainMOC save:&error]) {
            
            // TODO: Generalized way to handle this error?
            DLog(@"WARNING: Unresolved error during save: %@, %@", error, [error userInfo]);
        } else {
            returnValue = YES;
        }
    } else {
        
        DLog(@"WARNING: Couldn't access the main thread MOC during save.");
    }
    
    return returnValue;
}

// for UIKit-related use
- (NSManagedObjectContext *)mainThreadMOC {
    
    return [self mainThreadManagedObjectContext];
}

// Return a MOC that's not on the main thread for background work.
- (NSManagedObjectContext *)workingMOC {
    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        NSManagedObjectContext *moc = [[NSManagedObjectContext alloc] init];
//        [moc setPersistentStoreCoordinator:coordinator];
//        return moc;
//    }
//    return nil;
    
    return nil; // until implemented
}


#pragma mark - Data Import Utilities

- (NSDateFormatter *)iso8601DateFormatter {
    
    if (!_dateFormatter) {
        
        _dateFormatter = [[NSDateFormatter alloc] init];
        
        [_dateFormatter setDateFormat:ISO_8601_DATE_FORMAT];
    }
    
    return _dateFormatter;
}

// see link to spec above, where key/value constants are defined
- (NSDictionary *)flattenedGeoJSONFeature:(NSDictionary *)feature {
    
    NSDictionary *geometryDictionary = [feature objectForKey:kGeoJSONGeometryKey];
    NSString *typeString = [feature objectForKey:kGeoJSONTypeKey];
    
    if (!geometryDictionary || !typeString || ![typeString isEqualToString:kGeoJSONFeatureValue]) {
        DLog(@"WARNING: Invalid feature: %@", feature);
        return nil;
    }
    
    NSArray *coordinatesArray = [geometryDictionary objectForKey:kGeoJSONCoordinatesKey];
    typeString = [geometryDictionary objectForKey:kGeoJSONTypeKey];
    
    if (!coordinatesArray || !typeString || ![typeString isEqualToString:kGeoJSONPointValue]) {
        DLog(@"WARNING: Invalid geometry value in feature: %@", feature);
        return nil;
    }
    
    // be tolerant of GeoJSON data with no properties? It is required but can be null.
    NSDictionary *properties = [feature objectForKey:kGeoJSONPropertiesKey];
    if (!properties) {
        DLog(@"WARNING: properties key not found in feature: %@", feature);
        return nil;
    }
    
    NSUInteger capacity = [properties count] + 3;
    
    NSMutableDictionary *flatDictionary = [NSMutableDictionary dictionaryWithCapacity:capacity];
    
    // make these keys constants if you use them elsewhere
    [flatDictionary addEntriesFromDictionary:@{ @"latitude" : coordinatesArray[1],
                                                @"longitude" : coordinatesArray[0]
                                              }];
    
    [flatDictionary addEntriesFromDictionary:properties];
    
    // this is not required, so test for it
    // it could be an integer or a string
    id idValue = [feature objectForKey:kGeoJSONIDKey];
    
    if (idValue) {
        [flatDictionary addEntriesFromDictionary:@{@"id" : idValue }];
    }
    
    return flatDictionary;
}

@end
