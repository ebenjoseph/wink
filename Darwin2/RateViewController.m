//
//  RateViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/7/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "RateViewController.h"
#import "ECSlidingViewController.h"
#import "ChatViewController.h"
#import "WinksViewController.h"

@interface RateViewController ()

@end

@implementation RateViewController
@synthesize imageView;
@synthesize parseUser;
@synthesize userImage;
@synthesize username, menuBtn, ratingNum, currentRating, currentSliderValue;
@synthesize ratingNumber;
@synthesize slider, submitButton, cornerFlag;
@synthesize parseArray, currentRatingAvg, winkArray, userWinkArray, ratingArray, winkButton, locationLabel, numRatings;

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
    
    height = [[UIScreen mainScreen]bounds].size.height;
    
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    */
    
    //winkButton.layer.borderColor = [UIColor blackColor].CGColor;
    //winkButton.layer.borderWidth = 1.0;
    
    [imageView setImage:userImage];
    
    ratingNumber.textColor = [UIColor colorWithRed:(192/255.0) green:(80/255.0) blue:(77/255.0) alpha:1.0];
    
    geocoder = [[CLGeocoder alloc]init];
    
    rateActionFlag = 0;
    winkActionFlag = 0;
    
    [self queryParseUsers];

    self.title = parseUser.username;
    username.text = parseUser.username;
    
    //Set up location label
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


- (void)queryParseUsers
{
    NSLog(@"Starting data query");
    
    PFQuery *query = [PFQuery queryWithClassName:@"rating"];
    PFRelation *relation = [parseUser relationForKey:kWinksKey];
    PFRelation *userRelation = [[PFUser currentUser] relationForKey:kWinksKey];
    
    //[query includeKey:@"user"];
    [query whereKey:@"user" equalTo:parseUser];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            parseArray = [[NSArray alloc]initWithArray:objects];
            //NSLog(@"%@", parseArray);
            PFRelation *ratingRelation = [[parseArray objectAtIndex:0] relationForKey:@"userRated"];
            [[ratingRelation query]findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    ratingArray = [[NSArray alloc]initWithArray:objects];
                }
            }];
            
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
            
            [[relation query]findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    winkArray = [[NSArray alloc]initWithArray:objects];
                    //NSLog(@"%@", winkArray);
                    
                    [[userRelation query]findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error)
                        {
                            userWinkArray = [[NSArray alloc]initWithArray:objects];
                            //NSLog(@"%@", userWinkArray);
                            
                        }
                    }];
                }
            }];

        }
    }];
    
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)sliderValueChanged:(id)sender
{
    int sliderValue = (int)roundf(slider.value);
    ratingNumber.text = [NSString stringWithFormat:@"%d", sliderValue];
    if (sliderValue <= 7)
    {
        submitButton.imageView.image = [UIImage imageNamed:@"redsubmit.png"];
        ratingNumber.textColor = [UIColor colorWithRed:(192/255.0) green:(80/255.0) blue:(77/255.0) alpha:1.0];
    }
    else
    {
        submitButton.imageView.image = [UIImage imageNamed:@"greensubmit.png"];
        ratingNumber.textColor = [UIColor colorWithRed:(39/255.0) green:(206/255.0) blue:(60/255.0) alpha:1.0];
    }

    currentSliderValue = [NSNumber numberWithInt:sliderValue];
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

//RATING SECTION

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
    int i;
    for (i=0; i<[ratingArray count]; i++)
    {
        PFObject *ratingObject = ratingArray[i];
        NSString *ratingUsername = [ratingObject objectForKey:@"username"];
        NSLog(@"%@", ratingUsername);
        if ([[PFUser currentUser].username isEqualToString:ratingUsername])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:already message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            flag = 1;
        }
    }
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
        
        [dataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {

            }
        }];
        
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
            float newAvg = temp*1.0 / numRatings2;
            newRatingNum = [NSNumber numberWithFloat:newAvg];
            newNumRatings = [NSNumber numberWithInt:numRatings2];
        }
        
        [dataObject setObject:newRatingNum forKey:@"currentRating"];
        [dataObject setObject:newNumRatings forKey:@"numRatings"];
        [dataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating Added" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating Didn't Process" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
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

- (IBAction)wink:(id)sender
{
    flag = 0;
    NSString *title = [NSString stringWithFormat:@"You winked at %@!", username.text];
    NSString *already = [NSString stringWithFormat:@"You already winked at %@", username.text];
    NSString *trial = [NSString stringWithFormat:@"Sorry, only admitted members can wink at each other"];
    NSString *success = [NSString stringWithFormat:@"%@ has winked at you too!", username.text];
    NSString *successSubtext = [NSString stringWithFormat:@"Check out your Winks page to chat with %@", username.text];
    
    //Don't allow trial members to wink
    NSLog(@"%@", kUserStatus);
    
    if ([kUserStatus isEqualToString:kTrial])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:trial message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
        [alert show];
        
        flag = 1;
    }
    
    //First check to make sure you haven't already winked at user
    if (!flag)
    {
        int i;
        for (i=0; i<[userWinkArray count]; i++)
        {
            PFObject *winkObject = userWinkArray[i];
            NSString *winkUsername = [winkObject objectForKey:@"username"];
            if ([parseUser.username isEqualToString:winkUsername])
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:already message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
                
                flag = 1;
            }
        }
        if (winkActionFlag)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:already message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            
            flag = 1;
        }
    }
    
    //SET UP SUBSCRIPTIONS IF A WINK IS GIVEN
    
    //If you haven't, then proceed
    if (!flag)
    {
        //Mixpanel
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Wink"];
        [mixpanel flush];
        
        winkActionFlag = 1;
        
        PFRelation *relation = [[PFUser currentUser] relationForKey:kWinksKey];
        [relation addObject:parseUser];
        
        //Set up subscriptions
        PFInstallation *currentInstallation = [PFInstallation currentInstallation];
        NSString *channelID = [NSString stringWithFormat:@"w%@-%@",[PFUser currentUser].objectId, parseUser.objectId];
        [currentInstallation addUniqueObject:channelID forKey:kChannelsKey];
        
        currentInstallation[kUserKey] = [PFUser currentUser];
        [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                int x;
                for (x = 0; x < [winkArray count]; x++)
                {
                    PFObject *winkObject = winkArray[x];
                    NSString *winkUsername = [winkObject objectForKey:@"username"];
                    if ([[PFUser currentUser].username isEqualToString:winkUsername])
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:success message:successSubtext delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Okay!", nil];
                        [alert show];
                        
                        flag = 1;
                        
                        //RUN NOTIFICATIONS
                        //NOTIFY OTHER USER
                        
                        NSString *channelID2 = [NSString stringWithFormat:@"w%@-%@", parseUser.objectId, [PFUser currentUser].objectId];
                        PFQuery *pushQuery = [PFInstallation query];
                        [pushQuery whereKey:kUserKey equalTo:[PFUser currentUser]];
                        //[pushQuery whereKey:kChannelsKey equalTo:channelID2];
                        NSString *fullPushText = [NSString stringWithFormat:@"%@ has winked at you too!", [PFUser currentUser].username];
                        
                        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                              fullPushText, @"alert",
                                              @"Increment", @"badge",
                                              nil];
                        PFPush *push = [[PFPush alloc] init];
                        
                        //TESTING
                        //[push setChannels:[NSArray arrayWithObjects:self.currentUser.username, nil]];
                        
                        [push setChannels:[NSArray arrayWithObjects:channelID2, nil]];
                        [push setData:data];
                        [push sendPushInBackground];
                        
                        [self createChatRoom];
                        
                    }
                }
                
                [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)
                    {
                        if (!flag)
                        {
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                            [alert show];
                        }
                        
                    }
                    else
                    {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Rating Didn't Process" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                    }
                }];
            }
        }];
        
        
    }
    
}

- (void)createChatRoom
{
    NSLog(@"Creating Chat Room");
    
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    [queryForChatRoom whereKey:@"user2" equalTo:parseUser];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user1" equalTo:parseUser];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if ([objects count] == 0)
        {
            PFObject *chatroom = [PFObject objectWithClassName:@"ChatRoom"];
            [chatroom setObject:[PFUser currentUser] forKey:@"user1"];
            [chatroom setObject:parseUser forKey:@"user2"];
            
            //making chatrooms editable by both parties
            PFACL *dataACL = [PFACL ACLWithUser:parseUser];
            [dataACL setPublicWriteAccess:YES];
            [dataACL setPublicReadAccess:YES];
            chatroom.ACL = dataACL;
            
            [chatroom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                //ChatViewController *cvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Chat"];
                //[self presentViewController:cvc animated:(YES) completion:nil];
            }];
        }
    }];
    
}

/*
- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        WinksViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"Winks"];
        
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = wvc;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }
}
*/

- (IBAction)nextUser:(id)sender
{
    [self.view removeFromSuperview];
    
}



@end

