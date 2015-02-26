//
//  ViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/18/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "ViewController.h"
#import "SplashPageController.h"
#import "SlideNavigationController.h"
#import <Parse/Parse.h>

@interface ViewController ()

@end

@implementation ViewController
@synthesize checker;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSLog(@"%@", [PFUser currentUser]);
    
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
    
    self.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithPatternImage:image];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Loaded Login Page"];
    [mixpanel flush];

    //[PFUser logOut];

}

- (void)viewDidAppear:(BOOL)animated
{
    checker = 0;
    
    PFObject *userObject = [[PFUser currentUser] objectForKey:@"username"];
    if (userObject)
    {
        //[self queryParse];
    }
    
    NSLog(@"%d", flag);
    
    //Set Checker
    
    if (userObject && flag == 1)
    {
        checker = 1;
    }
    else if (userObject)
    {
        NSLog(@"User: %@", [PFUser currentUser]);
        
        //Set checker here to bypass login screen
        checker = 2;
    }
    
    
    //Actions
    if (checker == 0)
    {
        login = [[PFLogInViewController alloc]init];
        //[self.view addSubview:login.view];
        //[self addChildViewController:login];
        [self presentViewController:login animated:NO completion:nil];
        
        //Set up desgin for Login Screen
        
        login.view.backgroundColor = [UIColor whiteColor];//[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBG.png"]];
        
        login.logInView.logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"winktitle.png"]];
        [login.logInView.logo setFrame:CGRectMake(login.logInView.logo.frame.origin.x, login.logInView.logo.frame.origin.y, 123.0, 69.5)];
        login.logInView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        login.logInView.usernameField.textColor = [UIColor blackColor];
        login.logInView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        login.logInView.passwordField.textColor = [UIColor blackColor];
        login.logInView.dismissButton.hidden = YES;
        
        //Set up design for Sign up Screen
        
        login.signUpController.view.backgroundColor = [UIColor whiteColor]; //[UIColor colorWithPatternImage:[UIImage imageNamed:@"loginBG.png"]];
        login.signUpController.signUpView.logo = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"winktitle.png"]];
        [login.signUpController.signUpView.logo setFrame:CGRectMake(login.signUpController.signUpView.logo.frame.origin.x, login.signUpController.signUpView.logo.frame.origin.y, 123.0, 69.5)];
        login.signUpController.signUpView.usernameField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        login.signUpController.signUpView.usernameField.textColor = [UIColor blackColor];
        login.signUpController.signUpView.passwordField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        login.signUpController.signUpView.passwordField.textColor = [UIColor blackColor];
        login.signUpController.signUpView.emailField.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.45];
        login.signUpController.signUpView.emailField.textColor = [UIColor blackColor];
    
        login.delegate = self;
        login.signUpController.delegate = self;
    }
    else if (checker == 1)
    {
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Please verify your email before proceeding" message:nil delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Email Verified", nil];
        [alert show];
        
        */
        
        SplashPageController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"Splash"];
        [self presentViewController:second animated:(YES) completion:nil];
        
    }
    else if (checker == 2)
    {
        //[self performSegueWithIdentifier:@"mainSegue" sender:nil];
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Re-opened App"];
        [mixpanel flush];
        
        SlideNavigationController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideNav"];
        [self presentViewController:svc animated:(YES) completion:nil];
    }
    
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [[PFUser currentUser] deleteInBackground];
    }
    else
    {
        [self queryParse];
    }
}


- (void)queryParse
{
    
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    
    [query whereKey:@"username" equalTo:[PFUser currentUser].username];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseArray = [[NSArray alloc]initWithArray:objects];
            PFUser *user = parseArray[0];
            NSNumber *emailVerified = [user objectForKey:@"emailVerified"];
            if ([emailVerified boolValue])
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                
                [[PFUser currentUser] setObject:kTrial forKey:kStatusKey];
                [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"inChatRoom"];
                [[PFUser currentUser] saveInBackground];
                
                //[self performSegueWithIdentifier:@"splashSegue" sender:nil];
                Mixpanel *mixpanel = [Mixpanel sharedInstance];
                [mixpanel track:@"Created Account"];
                [mixpanel flush];
                
                SplashPageController *second = [self.storyboard instantiateViewControllerWithIdentifier:@"Splash"];
                [self presentViewController:second animated:(YES) completion:nil];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Email not verified" message:@"Please re-check your email and verify it before proceeding" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Email Verified", nil];
                [alert show];
                
                //[[PFUser currentUser] deleteInBackground];
                
            }
        }
    }];

}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user
{
    checker = 1;
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user
{
    flag = 1;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Verify Email" message:@"An email has been sent to the given address. Please check and verify your email before proceeding" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Email Verified", nil];
    [alert show];
    
    //[login.view removeFromSuperview];
    //[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
