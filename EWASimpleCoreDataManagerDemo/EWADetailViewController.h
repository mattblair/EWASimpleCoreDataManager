//
//  EWADetailViewController.h
//  EWASimpleCoreDataManagerDemo
//
//  Created by Matt Blair on 3/16/14.
//  Copyright (c) 2014 Elsewise. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EWADetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
