//
//  EWAMasterViewController.h
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EWADetailViewController;

@interface EWAMasterViewController : UITableViewController

@property (strong, nonatomic) EWADetailViewController *detailViewController;

@end
