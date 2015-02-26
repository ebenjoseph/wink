//
//  SlideViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/24/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "SlideViewController.h"
#import "ProfileViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "PreferencesViewController.h"
#import "MenuViewController.h"
#import "TransitionAnimator.h"

@interface SlideViewController () <CLLocationManagerDelegate, UIViewControllerTransitioningDelegate>

@end

@implementation SlideViewController
{
    CLLocationManager *locManager;
}

@synthesize userImage, menuBtn;

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
    
    //kBadgeNumber = @"2";
    
    [self queryParse];
    
    //Get current location
    locManager = [[CLLocationManager alloc]init];
    locManager.delegate = self;
    locManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locManager startUpdatingLocation];
    
    
    ProfileViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Profile"];
    //pvc.userImage = userImage;
    self.topViewController = pvc;
    
    //Set up settings bar button
    UIBarButtonItem *settingsButton = [[UIBarButtonItem alloc]initWithTitle:@"\u2699" style:UIBarButtonItemStylePlain target:self action:@selector(showSettings)];
    NSDictionary *textDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIColor blackColor], NSForegroundColorAttributeName,
                                    [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:26.0], NSFontAttributeName, nil];
    [settingsButton setTitleTextAttributes:textDictionary forState:UIControlStateNormal];
    
    self.navigationItem.rightBarButtonItem = settingsButton;
    
    //Set up back bar button top open menu
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        NSLog(@"Make underlying controller");
        MenuViewController *mvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
        self.slidingViewController.underLeftViewController = mvc;
    }
    
    //Set up menu bar button
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(0,0,25,25);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.menuBtn];
    

    UIBarButtonItem *menuButton = [[UIBarButtonItem alloc]initWithCustomView:menuBtn];
    [menuButton setTitleTextAttributes:textDictionary forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = menuButton;
    
    self.title = @"Wink";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSettings
{
    //PreferencesViewController *prvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Preferences"];
    //self.topViewController = prvc;
    //NSLog(@"%@", self.topViewController);
    
    UIStoryboard *myStoryboard = self.storyboard;
    PreferencesViewController *userInfo = [myStoryboard instantiateViewControllerWithIdentifier:@"Preferences"];
    self.topViewController = userInfo;
    userInfo.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
    userInfo.transitioningDelegate = self;
    userInfo.modalPresentationStyle = UIModalPresentationCustom;
    
    //[self presentViewController:userInfo animated:YES completion:nil];
    
}

- (IBAction)revealMenu:(id)sender
{
    [self anchorTopViewTo:ECRight];
}

#pragma mark - fix me

//This should only be run once - not necessary unless preferences are updated! FIX ME!!!


- (void)queryParse
{
    NSLog(@"starting browse query");
    
    PFQuery *query = [PFQuery queryWithClassName:@"info"];
    
    //[query includeKey:@"user"];
    
    [query whereKey:kUserKey equalTo:[PFUser currentUser]];
    [query includeKey:kUserKey];
    
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        if (!error)
        {
            parseObject = object;
            kUserSex = [parseObject objectForKey:@"sex"];
            kUserSeeking = [parseObject objectForKey:@"seeking"];
            kUserDistance = [parseObject objectForKey:@"distance"];
            kUserMinAge = [parseObject objectForKey:@"minAge"];
            kUserMaxAge = [parseObject objectForKey:@"maxAge"];
            
            PFUser *parseUser = [parseObject objectForKey:kUserKey];
            kUserStatus = [parseUser objectForKey:kStatusKey];
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

#pragma mark CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"%@", error);
    NSLog(@"Failed to get a location");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"Locations: %@", locations);
    CLLocation *currentLocation = locations.lastObject;
    if (currentLocation != nil)
    {
        
        PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
        kPFGeoPoint = geoPoint;
        kUserLatitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];
        kUserLongitude = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        
        PFUser *currentUser = [PFUser currentUser];
        
        [currentUser setObject:geoPoint forKey:@"location"];
        [currentUser saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSLog(@"Saved Location");
                [parseObject setObject:geoPoint forKey:@"location"];
                [parseObject saveInBackground];
                [locManager stopUpdatingLocation];
            }
        }];
        
    }
    
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransitionAnimator *animator = [[TransitionAnimator alloc]init];
    return  animator;
}

@end
