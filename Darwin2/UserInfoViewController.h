//
//  UserInfoViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface UserInfoViewController : UIViewController
{
    NSString *sexChoice;
    NSNumber *ageChoice;
    NSString *seekingChoice;
    NSString *factEntry;
}

@property (strong, nonatomic) IBOutlet UIView *infoView;

@property (strong, nonatomic) IBOutlet UISegmentedControl *sex;
@property (strong, nonatomic) IBOutlet UITextField *age;
@property (strong, nonatomic) IBOutlet UISegmentedControl *seeking;
@property (strong, nonatomic) IBOutlet UITextField *fact;

- (IBAction)screenTap:(id)sender;

- (IBAction)submit:(id)sender;

@end
