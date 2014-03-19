//
//  Composer.h
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/19/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Composer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * myRating;
@property (nonatomic, retain) NSNumber * alive;
@property (nonatomic, retain) NSDate * birthDate;
@property (nonatomic, retain) NSString * style;
@property (nonatomic, retain) NSNumber * numberOfWorks;
@property (nonatomic, retain) NSString * comments;

@end
