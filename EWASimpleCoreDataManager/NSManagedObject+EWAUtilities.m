//
//  NSManagedObject+EWAUtilities.m
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise LLC. MIT License.
//

#import "NSManagedObject+EWAUtilities.h"

@implementation NSManagedObject (EWAUtilities)

- (void)setValuesFromJSONDictionary:(NSDictionary *)jsonDictionary withDateFormat:(NSString *)dateFormat excludingProperties:(NSArray *)propertiesToExclude {
    
    //TODO: move this to data manager, so you only create once
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    if (!dateFormat)
        dateFormat = ISO_8601_DATE_FORMAT;
    
    [dateFormatter setDateFormat:dateFormat];
    
    // future-proof introspection of keys
    NSMutableDictionary *keysToSet = [[[self entity] attributesByName] mutableCopy];
    
    if (propertiesToExclude) {
        [keysToSet removeObjectsForKeys:propertiesToExclude];
    }
    
    for (NSString *keyName in keysToSet) {
        
        id valueFromJSON = [jsonDictionary objectForKey:keyName];
        
        // NSNull is generated if JSON has "key": null in it
        if (valueFromJSON == nil || [valueFromJSON isKindOfClass:[NSNull class]]) {
            // ignore it
            continue;
        }
        
        // handle conversion, then set it
        NSAttributeType attributeType = [[keysToSet objectForKey:keyName] attributeType];
        
        switch (attributeType) {
            case NSStringAttributeType: {
                
                if (([valueFromJSON isKindOfClass:[NSNumber class]])) {
                    valueFromJSON = [valueFromJSON stringValue];
                } else {
                    NSLog(@"WARNING: Value %@ was not an NSNumber. String conversion failed.", valueFromJSON);
                }
                break;
            }
                
            case NSInteger16AttributeType:
            case NSInteger32AttributeType:
            case NSInteger64AttributeType: {
                
                if (([valueFromJSON isKindOfClass:[NSString class]])) {
                    valueFromJSON = [NSNumber numberWithInteger:[valueFromJSON integerValue]];
                } else {
                    NSLog(@"WARNING: Value %@ was not a string. Integer conversion failed.", valueFromJSON);
                }
                break;
            }
                
            case NSBooleanAttributeType: {
                
                if (([valueFromJSON isKindOfClass:[NSString class]])) {
                    valueFromJSON = [NSNumber numberWithInteger:[valueFromJSON integerValue]];
                } else {
                    NSLog(@"WARNING: Value %@ was not a string. BOOL conversion failed.", valueFromJSON);
                }
                break;
            }
                
            case NSFloatAttributeType: {
                
                if (([valueFromJSON isKindOfClass:[NSString class]])) {
                    valueFromJSON = [NSNumber numberWithDouble:[valueFromJSON doubleValue]];
                } else {
                    NSLog(@"WARNING: Value %@ was not a string. Float conversion failed.", valueFromJSON);
                }
                break;
            }
                
            case NSDateAttributeType: {
                
                if (([valueFromJSON isKindOfClass:[NSString class]])) {
                    valueFromJSON = [dateFormatter dateFromString:valueFromJSON];
                } else {
                    NSLog(@"WARNING: Value %@ was not a string. Date conversion failed.", valueFromJSON);
                }
                break;
            }
                
            default: {
                
                NSLog(@"No conversion made for %@ of class %@", valueFromJSON, [valueFromJSON class]);
                break;
            }
        }
        
        // replaces original if else ladder...
        /*
        if ((attributeType == NSStringAttributeType) && ([newValue isKindOfClass:[NSNumber class]])) {
            newValue = [newValue stringValue];
        } else if (((attributeType == NSInteger16AttributeType) || (attributeType == NSInteger32AttributeType) || (attributeType == NSInteger64AttributeType) || (attributeType == NSBooleanAttributeType)) && ([newValue isKindOfClass:[NSString class]])) {
            newValue = [NSNumber numberWithInteger:[newValue integerValue]];
        } else if ((attributeType == NSFloatAttributeType) &&  ([newValue isKindOfClass:[NSString class]])) {
            newValue = [NSNumber numberWithDouble:[newValue doubleValue]];
        } else if ((attributeType == NSDateAttributeType) && ([newValue isKindOfClass:[NSString class]])) {
            newValue = [theDataFormatter dateFromString:newValue];
        }
        */
        
        // save to change type of newValue above?
        [self setValue:valueFromJSON forKey:keyName];
    }
}

- (void)setValuesFromJSONDictionary:(NSDictionary *)jsonDictionary withDateFormat:(NSString *)dateFormat {
    
    [self setValuesFromJSONDictionary:jsonDictionary withDateFormat:dateFormat excludingProperties:nil];
}


- (void)setValuesFromJSONDictionary:(NSDictionary *)jsonDictionary {
    
    [self setValuesFromJSONDictionary:jsonDictionary withDateFormat:nil];
}

@end
