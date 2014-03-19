//
//  NSManagedObject+EWAUtilities.h
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise LLC. MIT License.
//

// Adapted from Tom Harrington's Saving JSON to Core Data:
// http://www.cimgf.com/2011/06/02/saving-json-to-core-data/
//
// Differences from that approach:
// 1. I'm passing in a date format string. By default, it will use ISO 8601.
// 2. Properties listed in the excludingProperties argument will be filtered out
//   of the list before enumerating. This is so properties which require more
//   complex handling, like relationships or calculated values, can be set directly.
//
// In this followup post, he generalized this approach to NSObject:
// http://www.cimgf.com/2012/01/11/handling-incoming-json-redux/

#import <CoreData/CoreData.h>

@interface NSManagedObject (EWAUtilities)

- (void)setValuesFromJSONDictionary:(NSDictionary *)jsonDictionary withDateFormatter:(NSDateFormatter *)dateFormatter;

- (void)setValuesFromJSONDictionary:(NSDictionary *)jsonDictionary withDateFormatter:(NSDateFormatter *)dateFormatter excludingProperties:(NSArray *)propertiesToExclude;

@end
