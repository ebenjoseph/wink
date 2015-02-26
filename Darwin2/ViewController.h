//
//  ViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/18/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface ViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate>
{
    PFLogInViewController *login;
    
    IBOutlet UITextField *setUsernameField;
    IBOutlet UITextField *setPasswordField;
    
    IBOutlet UITextField *usernameField;
    IBOutlet UITextField *passwordField;
    
    NSArray *parseArray;
    PFObject *imageObject;
    int flag;
    
    NSMutableDictionary *dict;
}

@property int checker;

//- (IBAction)submitNewUser:(id)sender;
//- (IBAction)login:(id)sender;
//- (IBAction)screenTap:(id)sender;



@end
