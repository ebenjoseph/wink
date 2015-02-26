//
//  TrialViewController.m
//  Wink
//
//  Created by Eli Ben-Joseph on 9/22/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "TrialViewController.h"

@interface TrialViewController ()

@property (strong, nonatomic) NSMutableArray *userArray;
@property (strong, nonatomic) NSMutableArray *imageFileArray;
@property (strong, nonatomic) NSMutableArray *finalUserArray;

@end

@implementation TrialViewController
@synthesize imageView, userImage, locationLabel, username, submitButton, numRatings, currentRatingAvg, ratingNumber, slider, cornerFlag;

-(NSMutableArray *)userArray
{
    if (!_userArray)
    {
        _userArray = [[NSMutableArray alloc] init];
    }
    return _userArray;
}

-(NSMutableArray *)imageFileArray
{
    if (!_imageFileArray)
    {
        _imageFileArray = [[NSMutableArray alloc] init];
    }
    return _imageFileArray;
}

-(NSMutableArray *)finalUserArray
{
    if (!_finalUserArray)
    {
        _finalUserArray = [[NSMutableArray alloc] init];
    }
    return _finalUserArray;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    height = [[UIScreen mainScreen]bounds].size.height;
    
    //Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    ratingNumber.textColor = [UIColor colorWithRed:(192/255.0) green:(80/255.0) blue:(77/255.0) alpha:1.0];
    
    geocoder = [[CLGeocoder alloc]init];
    
    rateActionFlag = 0;
    userCounter = 0;
    
    [self queryParse];
    
}


- (void)queryParse
{
    noUsers = NO;
    
    NSString *sexSeeking = @"Both";
    NSString *userSexConverted;
    
    //Conversions
    if ([kUserSeeking isEqualToString:@"Men"])
    {
        sexSeeking = @"Male";
    }
    else if ([kUserSeeking isEqualToString:@"Women"])
    {
        sexSeeking = @"Female";
    }
    
    if ([kUserSex isEqualToString:@"Male"])
    {
        userSexConverted = @"Men";
    }
    else
    {
        userSexConverted = @"Women";
    }
    
    PFRelation *rateRelation = [[PFUser currentUser] relationForKey:@"ratedUser"];
    
    [[rateRelation query]findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
    {
        if (!error)
        {
            ratingArray = [[NSArray alloc]initWithArray:objects];
            
            PFQuery *query = [PFQuery queryWithClassName:@"photo"];
            PFQuery *infoQuery = [PFQuery queryWithClassName:@"info"];
            PFQuery *ratingQuery = [PFQuery queryWithClassName:@"rating"];
            
            [query whereKey:kUserKey notEqualTo:[PFUser currentUser]];
            [query whereKey:kUserKey notContainedIn:ratingArray];
            [query includeKey:kUserKey];
            [query includeKey:kRatingKey];
            
            [ratingQuery whereKey:kUserKey notEqualTo:[PFUser currentUser]];
            [ratingQuery whereKey:kUserKey notContainedIn:ratingArray];
            [ratingQuery includeKey:kUserKey];
            
            //Set seeking preferences
            if (![sexSeeking isEqualToString:@"Both"])
            {
                [infoQuery whereKey:@"sex" equalTo:sexSeeking];
                [infoQuery whereKey:@"seeking" containedIn:@[userSexConverted, @"Both"]];
            }
            else
            {
                [infoQuery whereKey:@"seeking" containedIn:@[userSexConverted, @"Both"]];
            }
            
            //Set age preferences
            if ([kUserMinAge integerValue] != 0 && [kUserMaxAge integerValue] != 0)
            {
                [infoQuery whereKey:@"age" greaterThanOrEqualTo:kUserMinAge];
                [infoQuery whereKey:@"age" lessThanOrEqualTo:kUserMaxAge];
            }
            
            //Set distances
            if ([kUserDistance isEqualToString:@"0-5mi"])
            {
                [infoQuery whereKey:@"location" nearGeoPoint:kPFGeoPoint withinMiles:5.0];
            }
            
            [query whereKey:kUserKey matchesKey:kUserKey inQuery:infoQuery];
            [ratingQuery whereKey:kUserKey matchesKey:kUserKey inQuery:infoQuery];
            
            //Order trial users by most recently created
            [ratingQuery orderByDescending:@"createdAt"];
            
            [ratingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    //Logic to remove rejected and admitted users
                    NSArray *tempArray = [[NSArray alloc]initWithArray:objects];
                    
                    int i;
                    for (i = 0; i < [tempArray count]; i++)
                    {
                        PFObject *tempObject = tempArray[i];
                        PFUser *tempUser = [tempObject objectForKey:kUserKey];
                        
                        int trialNum = 1;
                        if ([[tempUser objectForKey:kStatusKey] isEqualToString:kTrial])
                        {
                            NSDate *createDate;
                            createDate = [tempObject createdAt];
                            
                            NSDate *today = [NSDate date];
                            NSTimeInterval trial = [today timeIntervalSinceDate:createDate];
                            trial = trial/86400;
                            trial = floor(trial);
                            trialNum = (int)roundf(trial);
                            trialNum = 7 - trialNum;
                        }
                        
                        
                        if (![[tempUser objectForKey:kStatusKey] isEqualToString:kRejected] && trialNum >= 0 && ![[tempUser objectForKey:kStatusKey] isEqualToString:kAdmitted])
                        {
                            [self.userArray addObject:tempObject];
                        }
                        
                    }
                    
                    if ([self.userArray count])
                    {
                        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                            if (!error)
                            {
                                self.imageFileArray = [[NSMutableArray alloc]init];
                                self.imageFileArray = [objects mutableCopy];
                                
                                //Set up initial user
                                parseUser = [[self.userArray objectAtIndex:userCounter] objectForKey:kUserKey];
                                userCounter++;
                                [self queryCurrentUser];
                            }
                        }];
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There are no trial users to rate at this time" message:@"Please check again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                        
                        [activityIndicator stopAnimating];
                        submitButton.hidden = YES;
                        slider.hidden = YES;
                        ratingNumber.hidden = YES;
                    }
                    
                }
            }];
        }
    }];
    
    
    
}

- (void)queryCurrentUser
{
    self.title = parseUser.username;
    username.text = parseUser.username;
    
    [self geoCode];
    
    int i;
    for (i = 0; i < [self.imageFileArray count]; i++)
    {
        PFObject *imageObject = [self.imageFileArray objectAtIndex:i];
        PFFile *imageFile = [imageObject objectForKey:@"image"];
        PFUser *imageUser = [imageObject objectForKey:kUserKey];
        if ([imageUser.objectId isEqual:parseUser.objectId])
        {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    imageView.image = [UIImage imageWithData:data];
                }
            }];
        }
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"rating"];
    [query includeKey:@"user"];
    [query whereKey:@"user" equalTo:parseUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseArray = [[NSArray alloc]initWithArray:objects];
            
            NSNumber *currentUserRatingNum = [[parseArray objectAtIndex:0]objectForKey:kCurrentRatingKey];
            NSNumber *currentNumRatings = [[parseArray objectAtIndex:0]objectForKey:kNumRatingsKey];
            if ([currentUserRatingNum integerValue] == 0)
            {
                currentRatingAvg.text = @"0.0";
                numRatings.text = @"0";
            }
            else
            {
                NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
                [numberFormatter setMaximumFractionDigits:1];
                [numberFormatter setMinimumFractionDigits:1];
                currentRatingAvg.text = [numberFormatter stringFromNumber:currentUserRatingNum];
                numRatings.text = [currentNumRatings stringValue];
                
                if ([currentUserRatingNum floatValue] >= 7.5)
                {
                    cornerFlag.image = [UIImage imageNamed:@"greencorner.png"];
                }
            }
        }
    }];
    
    [activityIndicator stopAnimating];
}

- (IBAction)sliderValueChanged:(id)sender
{
    float sliderValue = roundf(slider.value * 2.0) / 2.0;
    ratingNumber.text = [NSString stringWithFormat:@"%.1f", sliderValue];
    if (sliderValue < 7.5)
    {
        submitButton.imageView.image = [UIImage imageNamed:@"redsubmit.png"];
        ratingNumber.textColor = [UIColor colorWithRed:(192/255.0) green:(80/255.0) blue:(77/255.0) alpha:1.0];
    }
    else
    {
        submitButton.imageView.image = [UIImage imageNamed:@"greensubmit.png"];
        ratingNumber.textColor = [UIColor colorWithRed:(39/255.0) green:(206/255.0) blue:(60/255.0) alpha:1.0];
    }
    
    currentSliderValue = [NSNumber numberWithFloat:sliderValue];
}

- (IBAction)submit:(id)sender
{
    //NSLog(@"Here");
    flag = 0;
    NSString *already = [NSString stringWithFormat:@"You already rated %@", username.text];
    NSString *trial = [NSString stringWithFormat:@"Sorry, only admitted members can submit ratings"];
    
    PFObject *dataObject = [parseArray objectAtIndex:0];
    ratingNum = [dataObject objectForKey:@"numRatings"];
    currentRating = [dataObject objectForKey:@"currentRating"];
    int numRatings2 = [ratingNum intValue];
    
    NSNumber *newRatingNum;
    NSNumber *newNumRatings;
    
    if ([kUserStatus isEqualToString:kTrial])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trial message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
        flag = 1;
    }
    
    //See if user has already been rated
    if (rateActionFlag)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:already message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
        flag = 1;
    }
    
    //If not, rate user
    if (!flag)
    {
        //Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Rating"];
        [mixpanel flush];
        
        rateActionFlag = 1;
        
        //Set userRated relation
        PFRelation *relation = [dataObject relationForKey:@"userRated"];
        [relation addObject:[PFUser currentUser]];
        
        //Set ratedUser relation
        PFRelation *relation2 = [[PFUser currentUser] relationForKey:@"ratedUser"];
        [relation2 addObject:parseUser];
        [[PFUser currentUser] saveInBackground];
        
        //Logic for setting ratings
        if (numRatings2 == 0)
        {
            numRatings2++;
            newRatingNum = currentSliderValue;
            newNumRatings = [NSNumber numberWithInt:numRatings2];
        }
        else
        {
            float temp = [currentRating floatValue] * numRatings2;
            temp += [currentSliderValue intValue];
            numRatings2++;
            float newAvg = temp * 1.0 / numRatings2;
            newRatingNum = [NSNumber numberWithFloat:newAvg];
            newNumRatings = [NSNumber numberWithInt:numRatings2];
        }
        
        [dataObject setObject:newRatingNum forKey:@"currentRating"];
        [dataObject setObject:newNumRatings forKey:@"numRatings"];
        [dataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                //pull up next user if possible
                if (userCounter < [self.userArray count])
                {
                    parseUser = [[self.userArray objectAtIndex:userCounter] objectForKey:kUserKey];
                    userCounter++;
                    rateActionFlag = 0;
                    
                    [activityIndicator startAnimating];
                    [self queryCurrentUser];
                }
                else
                {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There are no more trial users to rate at this time" message:@"Please check again later" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                    [alert show];
                    
                    submitButton.hidden = YES;
                    slider.hidden = YES;
                    ratingNumber.hidden = YES;
                }
                
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating Added" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                */
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating didn't process, please try again" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];
    }
    
    //NSLog(@"USERS:");
    //NSLog(@"%@", [PFUser currentUser]);
    //NSLog(@"%@", parseUser);
    
    // Dismiss this screen
    //[self.navigationController popViewControllerAnimated:NO];
}

- (void)geoCode
{
    PFGeoPoint *geoPoint = [parseUser objectForKey:@"location"];
    if (geoPoint)
    {
        userLocation = [[CLLocation alloc]initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        
        [geocoder reverseGeocodeLocation:userLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if (!error && [placemarks count] > 0)
            {
                placemark = [placemarks lastObject];
                NSString *locationString = [NSString stringWithFormat:@"%@, %@", placemark.locality, placemark.administrativeArea];
                locationLabel.text = locationString;
                
            }
            else
            {
                NSLog(@"%@", error);
            }
        }];
    }
    else
    {
        locationLabel.text = @"";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
