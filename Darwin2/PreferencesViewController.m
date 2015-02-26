//
//  PreferencesViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "PreferencesViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "SlideViewController.h"
#import "SlideNavigationController.h"

@interface PreferencesViewController ()

@end

@implementation PreferencesViewController

@synthesize distance, minAge, maxAge, menuBtn, sex, age, seeking, fact, prefView;

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
    
    prefView.layer.cornerRadius = 10;
    
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
     */
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened Preferences Page"];
    [mixpanel flush];
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        NSLog(@"Make underlying controller");
        MenuViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        self.slidingViewController.underLeftViewController = mvc;
        //[self.view addSubview:mvc.view];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    //Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [activityIndicator setBackgroundColor:[UIColor grayColor]];
    [activityIndicator setAlpha:0.5];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    distance.selectedSegmentIndex = 1;
    [self queryParse];
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)queryParse
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"info"];
    
    //[query includeKey:@"user"];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseArray = [[NSArray alloc]initWithArray:objects];
            //NSLog(@"%@", parseArray);
            NSNumber *currentMinAge = [[parseArray objectAtIndex:0]objectForKey:@"minAge"];
            NSNumber *currentMaxAge = [[parseArray objectAtIndex:0]objectForKey:@"maxAge"];
            NSString *currentDistance = [[parseArray objectAtIndex:0]objectForKey:@"distance"];
            NSString *currentSexChoice = [[parseArray objectAtIndex:0]objectForKey:@"sex"];
            NSNumber *currentAgeChoice = [[parseArray objectAtIndex:0]objectForKey:@"age"];
            NSString *currentSeekingChoice = [[parseArray objectAtIndex:0]objectForKey:@"seeking"];
            NSString *currentFact = [[parseArray objectAtIndex:0]objectForKey:@"fact"];
            
            if ([currentMinAge integerValue] != 0)
            {
                minAge.text = [currentMinAge stringValue];
            }
            
            if ([currentMaxAge integerValue] != 0)
            {
                maxAge.text = [currentMaxAge stringValue];
            }
            
            if ([currentDistance isEqualToString:@"0-5mi"])
            {
                distance.selectedSegmentIndex = 0;
            }
            else if ([currentDistance isEqualToString:@">5mi"])
            {
                distance.selectedSegmentIndex = 1;
            }
            
            if ([currentSexChoice isEqualToString:@"Male"])
            {
                sex.selectedSegmentIndex = 0;
            }
            else if ([currentSexChoice isEqualToString:@"Female"])
            {
                sex.selectedSegmentIndex = 1;
            }
            
            if ([currentAgeChoice integerValue] != 0)
            {
                age.text = [currentAgeChoice stringValue];
            }
            
            if ([currentSeekingChoice isEqualToString:@"Men"])
            {
                seeking.selectedSegmentIndex = 0;
            }
            else if ([currentSeekingChoice isEqualToString:@"Women"])
            {
                seeking.selectedSegmentIndex = 1;
            }
            else if ([currentSeekingChoice isEqualToString:@"Both"])
            {
                seeking.selectedSegmentIndex = 2;
            }
            
            fact.text = currentFact;
            
            [activityIndicator stopAnimating];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }
    }];
    
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

- (IBAction)submitPreferences:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Changed Preferences"];
    [mixpanel flush];
    
    int flag = 1;
    
    PFObject *infoObject = [parseArray objectAtIndex:0];
    
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
    
    //Check for fact
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
    
    //Check for min age
    if (![minAge.text integerValue] || [minAge.text integerValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter A Minimum Age" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        minAgeChoice = [NSNumber numberWithInteger:[minAge.text integerValue]];
    }
    
    //Check for max age
    if (![maxAge.text integerValue] || [maxAge.text integerValue] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please Enter A Maximum Age" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
        flag = 0;
    }
    else
    {
        maxAgeChoice = [NSNumber numberWithInteger:[maxAge.text integerValue]];
    }
    
    distanceChoice = [distance titleForSegmentAtIndex:distance.selectedSegmentIndex];
    sexChoice = [sex titleForSegmentAtIndex:sex.selectedSegmentIndex];
    seekingChoice = [seeking titleForSegmentAtIndex:seeking.selectedSegmentIndex];

    if (flag)
    {
        //Activity Indicator
        UIActivityIndicatorView *activityIndicator2 = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [activityIndicator2 setBackgroundColor:[UIColor grayColor]];
        [activityIndicator2 setAlpha:0.5];
        [activityIndicator2 setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator2.center = self.view.center;
        [self.view addSubview:activityIndicator2];
        [activityIndicator2 startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        [infoObject setObject:distanceChoice forKey:@"distance"];
        [infoObject setObject:minAgeChoice forKey:@"minAge"];
        [infoObject setObject:maxAgeChoice forKey:@"maxAge"];
        [infoObject setObject:sexChoice forKey:@"sex"];
        [infoObject setObject:ageChoice forKey:@"age"];
        [infoObject setObject:seekingChoice forKey:@"seeking"];
        [infoObject setObject:factEntry forKey:@"fact"];
        
        [infoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                [activityIndicator2 stopAnimating];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Preferences Updated" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];
        
        kUserSex = sexChoice;
        kUserSeeking = seekingChoice;
        kUserMinAge = minAgeChoice;
        kUserMaxAge = maxAgeChoice;
        kUserDistance = distanceChoice;
    }
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    SlideNavigationController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideNav"];
    [self presentViewController:svc animated:(YES) completion:nil];
}

- (IBAction)screenTap:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)closeWindow:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Closed Preferences Page"];
    [mixpanel flush];
    
    SlideNavigationController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideNav"];
    [self presentViewController:svc animated:(YES) completion:nil];
}

@end
