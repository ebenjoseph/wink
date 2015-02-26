//
//  UserInfoViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "UserInfoViewController.h"
#import "SlideNavigationController.h"

@interface UserInfoViewController ()

@end

@implementation UserInfoViewController
@synthesize sex, seeking, age, fact, infoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    infoView.layer.cornerRadius = 10;
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    sex.selectedSegmentIndex = -1;
    seeking.selectedSegmentIndex = -1;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)screenTap:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)submit:(id)sender
{
    NSNumber *minAge = [NSNumber numberWithInt:[kAgeMinKey intValue]];
    NSNumber *maxAge = [NSNumber numberWithInt:[kAgeMaxKey intValue]];
    int flag = 1;
    
    //Check for sex choice
    if (sex.selectedSegmentIndex == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter Your Sex" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        sexChoice = [sex titleForSegmentAtIndex:sex.selectedSegmentIndex];
    }
    
    //Check for age
    if (![age.text integerValue] || [age.text integerValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter Your Age" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        ageChoice = [NSNumber numberWithInteger:[age.text integerValue]];
    }
    
    //Check for seeking choice
    if (seeking.selectedSegmentIndex == -1)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter Your Sexual Preference" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        seekingChoice = [seeking titleForSegmentAtIndex:seeking.selectedSegmentIndex];
    }
    
    //Check for fact and make sure it's under 35chars
    if ([fact.text isEqualToString:@""] || [fact.text isEqualToString:@" "])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter A Fact About Yourself" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else if ([fact.text length] > 25)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please keep your fact under 25 characters" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        factEntry = fact.text;
    }
    
    //NSLog(@"sex: %@", sexChoice);
    //NSLog(@"age: %@", ageChoice);
    //NSLog(@"seeking: %@", seekingChoice);
    
    if (flag)
    {
        //Activity Indicator
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [activityIndicator setBackgroundColor:[UIColor grayColor]];
        [activityIndicator setAlpha:0.5];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = self.view.center;
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        //Create an info object and set default values
        PFObject *infoObject = [PFObject objectWithClassName:@"info"];
        [infoObject setObject:[PFUser currentUser] forKey:@"user"];
        [infoObject setObject:sexChoice forKey:@"sex"];
        [infoObject setObject:ageChoice forKey:@"age"];
        [infoObject setObject:seekingChoice forKey:@"seeking"];
        [infoObject setObject:factEntry forKey:@"fact"];
        [infoObject setObject:minAge forKey:@"minAge"];
        [infoObject setObject:maxAge forKey:@"maxAge"];
        [infoObject setObject:kDistanceKey forKey:@"distance"];
        
        //making preferences editable
        PFACL *infoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [infoACL setPublicWriteAccess:YES];
        [infoACL setPublicReadAccess:YES];
        infoObject.ACL = infoACL;
        
        [infoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                [activityIndicator stopAnimating];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                kUserSex = sexChoice;
                kUserSeeking = seekingChoice;
                
                SlideNavigationController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideNav"];
                [self presentViewController:svc animated:(YES) completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];
    }
    
}
@end
