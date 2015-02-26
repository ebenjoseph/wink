//
//  PreferencesViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"
#import "SlideViewController.h"

@interface PreferencesViewController : UIViewController
{
    NSString *distanceChoice;
    NSNumber *minAgeChoice;
    NSNumber *maxAgeChoice;
    NSString *sexChoice;
    NSNumber *ageChoice;
    NSString *seekingChoice;
    NSString *factEntry;
    
    NSArray *parseArray;
    UIViewController *previousController;
    
    UIActivityIndicatorView *activityIndicator;
}

@property (strong, nonatomic) IBOutlet UIView *prefView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *sex;
@property (strong, nonatomic) IBOutlet UITextField *age;
@property (strong, nonatomic) IBOutlet UISegmentedControl *seeking;
@property (strong, nonatomic) IBOutlet UITextField *fact;
@property (strong, nonatomic) IBOutlet UISegmentedControl *distance;
@property (strong, nonatomic) IBOutlet UITextField *minAge;
@property (strong, nonatomic) IBOutlet UITextField *maxAge;

@property (strong, nonatomic) UIButton *menuBtn;

- (IBAction)submitPreferences:(id)sender;
- (IBAction)screenTap:(id)sender;
- (IBAction)closeWindow:(id)sender;

@end
