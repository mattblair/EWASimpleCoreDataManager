//
//  DemoDataManager.m
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import "DemoDataManager.h"

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



@end
