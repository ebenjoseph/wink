//
//  ProfileViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/19/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "ProfileViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "SplashPageController.h"
#import "ViewController.h"
#import "SlideNavigationController.h"

@interface ProfileViewController ()

@property (strong, nonatomic) NSTimer *timer;

@end

@implementation ProfileViewController


@synthesize menuBtn, numRatingsLabel;
@synthesize userImage, currentRatingLabel, daysLeft, daysLeftTitle, statusLabel, currentRatingTitle, tableView;
@synthesize statusTitle, ratingsReceivedTitle;

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
    
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    */
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Profile"];
    [mixpanel flush];
    
    //Hide potentially unused labels
    daysLeftTitle.hidden = YES;
    daysLeft.hidden = YES;
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
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
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    //Timer for connectivity
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    remainingCounts = 7;
    
    self.title = [PFUser currentUser].username;
    
    //Refresh control
    /*
    refreshControl =  [[UIRefreshControl alloc] init];
    [self.view addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    */
    
    /*
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    menuBtn.frame = CGRectMake(7,7,34,34);
    [menuBtn setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.menuBtn];
    */
}

- (void)viewDidAppear:(BOOL)animated
{
    [self queryParse];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)queryParse
{
    PFQuery *query = [PFQuery queryWithClassName:@"photo"];
    
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseArray = [[NSMutableArray alloc]initWithArray:objects];
            imageObject = [parseArray objectAtIndex:0];
            PFFile *imageFile = [imageObject objectForKey:@"image"];
            createDate = [imageObject createdAt];
            
            NSDate *today = [NSDate date];
            NSTimeInterval trial = [today timeIntervalSinceDate:createDate];
            trial = trial/86400;
            trial = floor(trial);
            trialNum = (int)roundf(trial);
            trialNum = 7 - trialNum;
            if (trialNum < 0)
            {
                daysLeft.text = @"";
            }
            else
            {
                daysLeft.text = [NSString stringWithFormat:@"%d", trialNum];
            }
            
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    userImage = [UIImage imageWithData:data];
                    [imageView setImage:userImage];
                }
            }];
        }
    }];
    
    PFQuery *query2 = [PFQuery queryWithClassName:@"rating"];
    [query2 whereKey:@"user" equalTo:[PFUser currentUser]];
    [query2 includeKey:kUserKey];
    
    [query2 findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseRatingArray = [[NSMutableArray alloc]initWithArray:objects];
            ratingObject = [parseRatingArray objectAtIndex:0];
            currentRating = [ratingObject objectForKey:@"currentRating"];
            numRatings = [ratingObject objectForKey:@"numRatings"];
            float currentRatingFloat = [currentRating floatValue];
            NSLog(@"%@", currentRating);
            if (currentRatingFloat > 0)
            {
                NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc]init];
                [numFormatter setMaximumFractionDigits:1];
                [numFormatter setMinimumFractionDigits:1];
                currentRatingLabel.text = [numFormatter stringFromNumber:currentRating];
            }
            
            numRatingsLabel.text = [numRatings stringValue];
            
            PFUser *currentUser = [ratingObject objectForKey:kUserKey];
            
            //FINISH LOGIC
            if ([[currentUser objectForKey:kStatusKey] isEqualToString:kRejected])
            {
                [PFUser logOut];
                ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"one"];
                [self.view removeFromSuperview];
                [self presentViewController:vc animated:NO completion:nil];
            }
            else if ([[currentUser objectForKey:kStatusKey] isEqualToString:kTrial])
            {
                if ([currentRating floatValue] < 7.5)
                {
                    currentRatingLabel.textColor = [UIColor redColor];
                }
                
                if (trialNum <= -1 && [currentRating floatValue] >= 7.5)
                {
                    [currentUser setObject:kAdmitted forKey:kStatusKey];
                    [currentUser saveInBackground];
                    
                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                    [mixpanel track:@"User Admitted"];
                    [mixpanel flush];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Congratulations! You are an official Wink member" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Let's Go!", nil];
                    [alert show];
                    
                    SlideNavigationController *snc = [self.storyboard instantiateViewControllerWithIdentifier:@"SlideNav"];
                    [self presentViewController:snc animated:(YES) completion:nil];
                    
                    [activityIndicator stopAnimating];
                    [self.timer invalidate];
                }
                else if (trialNum <= -1 && [currentRating floatValue] < 7.5)
                {
                    [currentUser setObject:kRejected forKey:kStatusKey];
                    [currentUser saveInBackground];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, you didn't make the cut" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Logout", nil];
                    [alert show];
                    
                    Mixpanel *mixpanel = [Mixpanel sharedInstance];
                    [mixpanel track:@"User Rejected"];
                    [mixpanel flush];
                    
                    [PFUser logOut];
                    ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"one"];
                    [self.view removeFromSuperview];
                    [self presentViewController:vc animated:NO completion:nil];
                    
                    [activityIndicator stopAnimating];
                    [self.timer invalidate];
                }
                statusLabel.text = @"Trial";
                
                daysLeftTitle.hidden = NO;
                daysLeft.hidden = NO;
                
                [activityIndicator stopAnimating];
                [self.timer invalidate];
            }
            else
            {
                statusLabel.text = @"Member";
                daysLeftTitle.hidden = YES;
                
                [activityIndicator stopAnimating];
                [self.timer invalidate];
            }
            //Logic to determine if user is admitted
            
        }
    }];
    
}

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

- (void)countDown
{
    if (--remainingCounts == 0)
    {
        [self.timer invalidate];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're having difficulty connecting to the internet" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Close", nil];
        [alert show];
    }
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    [refreshControl endRefreshing];
    [parseArray removeAllObjects];
    [parseRatingArray removeAllObjects];
    [self queryParse];
}


@end
