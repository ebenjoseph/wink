//
//  BrowseViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/24/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "BrowseViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "SplashPageController.h"
#import "RateViewController.h"

@interface BrowseViewController ()

@property (strong, nonatomic) NSMutableArray *imageFileArray;
@property (strong, nonatomic) NSMutableArray *browseArray;
@property (strong, nonatomic) NSMutableArray *ratingArray;

@end

@implementation BrowseViewController

@synthesize menuBtn, userImage, browseCollection, userViewSelection, moreUsersButton, filterSelection;

-(NSMutableArray *)imageFileArray
{
    if (!_imageFileArray)
    {
        _imageFileArray = [[NSMutableArray alloc] init];
    }
    return _imageFileArray;
}

-(NSMutableArray *)browseArray
{
    if (!_browseArray)
    {
        _browseArray = [[NSMutableArray alloc] init];
    }
    return _browseArray;
}

-(NSMutableArray *)ratingArray
{
    if (!_ratingArray)
    {
        _ratingArray = [[NSMutableArray alloc] init];
    }
    return _ratingArray;
}

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
    height = [[UIScreen mainScreen]bounds].size.height;
    
    [self.browseCollection setBackgroundColor:[UIColor colorWithRed:(171/255.0) green:(171/255.0) blue:(171/255.0) alpha:1.0]];
    [self.browseCollection setSeparatorColor:[UIColor clearColor]];
    
    //Activity Indicator
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self queryParse];
    
    //NSLog(@"Lat: %@ Long: %@", kUserLatitude, kUserLongitude);
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed Browse List"];
    [mixpanel flush];
    
    filterType = 0;
    limitAdder = 0;
    
    userViewSelection.selectedSegmentIndex = 1;
    [self setUpUserSegmentedControl];
    
    UIImageView *lineView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"line.png"]];
    [lineView setFrame:CGRectMake(self.userViewSelection.frame.origin.x, (self.userViewSelection.frame.origin.y+35), 320.0, 1.0)];
    
    filterSelection.selectedSegmentIndex = 0;
    [self setUpSegmentedControlFilters];
    
    CGRect frame = filterSelection.frame;
    [filterSelection setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50.0)];
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]])
    {
        self.slidingViewController.underLeftViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    //Refresh control
    refreshControl =  [[UIRefreshControl alloc] init];
    [browseCollection addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
     
}


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed User"];
    [mixpanel flush];
    
    RateViewController *rvc = [segue destinationViewController];
    NSIndexPath *indexPath = sender;
    
    PFObject *passObject;
    
    if (filterType == 1)
    {
        passObject = [memberUsers objectAtIndex:indexPath.row];
    }
    else if (filterType == 2)
    {
        passObject = [trialUsers objectAtIndex:indexPath.row];
    }
    else
    {
        passObject = [self.browseArray objectAtIndex:indexPath.row];
    }
    
    PFUser *selectedUser = [passObject objectForKey:kUserKey];
    
    int i;
    for (i = 0; i < [self.imageFileArray count]; i++)
    {
        PFObject *imageObject = [self.imageFileArray objectAtIndex:i];
        PFFile *imageFile = [imageObject objectForKey:@"image"];
        PFUser *imageUser = [imageObject objectForKey:kUserKey];
        if ([imageUser.objectId isEqual:selectedUser.objectId])
        {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    [rvc.imageView setImage:[UIImage imageWithData:data]];
                }
            }];
        }
    }
    
    rvc.parseUser = selectedUser;
}

- (void)queryParse
{
    NSLog(@"starting browse query");
    
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
    
    NSLog(@"Seeking sex: %@", sexSeeking);
    NSLog(@"User sex converted: %@", userSexConverted);
    
    PFQuery *query = [PFQuery queryWithClassName:@"photo"];
    PFQuery *infoQuery = [PFQuery queryWithClassName:@"info"];
    PFQuery *ratingQuery = [PFQuery queryWithClassName:@"rating"];
    
    [query whereKey:kUserKey notEqualTo:[PFUser currentUser]];
    [query includeKey:kUserKey];
    [query includeKey:kRatingKey];
    
    [ratingQuery whereKey:kUserKey notEqualTo:[PFUser currentUser]];
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
    NSLog(@"%@", kUserMinAge);
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
    
    /*
    [infoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            imageFileArray = [[NSArray alloc]initWithArray:objects];
            NSLog(@"%@", imageFileArray);
        }
    }];
    */
    
    //[query includeKey:@"info.sex"];
    if (filterSelection.selectedSegmentIndex == 0)
    {
        [ratingQuery orderByDescending:@"createdAt"];
    }
    else if (filterSelection.selectedSegmentIndex == 1)
    {
        [ratingQuery orderByDescending:kCurrentRatingKey];
    }
    else
    {
        [ratingQuery orderByDescending:kNumRatingsKey];
    }
    
    //[query whereKey:@"info.sex" equalTo:kUserSeeking];
    
    [ratingQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            //Logic to remove rejected users from BrowseView
            NSArray *tempArray = [[NSArray alloc]initWithArray:objects];
            int limit;
            if (height == 480)
            {
                limit = 4;
                limitAdder = 3;
            }
            else
            {
                limit = 5;
                limitAdder = 4;
            }
            
            int i;
            //initializing a second counter to only count when objects are added to the array
            int j = 0;
            
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
                
                //Members only
                if (![[tempUser objectForKey:kStatusKey] isEqualToString:kRejected] && ![[tempUser objectForKey:kStatusKey] isEqualToString:kTrial] && trialNum >= 0)
                {
                    [self.ratingArray addObject:tempObject];
                    
                    //initialize browseArray with 3-4 objects
                    if (j < limit)
                    {
                        //NSLog(@"%d", j);
                        [self.browseArray addObject:tempObject];
                        j++;
                    }
                }
            }
            
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    self.imageFileArray = [[NSMutableArray alloc]init];
                    self.imageFileArray = [objects mutableCopy];
                    
                    //ratingArray = [[NSMutableArray alloc]init];
                    //ratingArray = [objects mutableCopy];
                    
                    [self userSelection:self];
                    //[browseCollection reloadData];
                    [activityIndicator stopAnimating];
                    
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

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
}

#pragma mark - UITableView data source

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (filterType == 1)
    {
        return [memberUsers count];
    }
    if (filterType == 2)
    {
        return [trialUsers count];
    }
    else
    {
        return [self.browseArray count];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"imageCell";
    BrowseViewCell *cell = (BrowseViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.cellView.layer.cornerRadius = 2;
    cell.cellView.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.cellView.layer.shadowOffset = CGSizeMake(0, 1);
    cell.cellView.layer.shadowOpacity = 0.5;
    cell.cellView.layer.shadowRadius = 2.0;
    cell.image.layer.cornerRadius = 2;
    
    PFObject *parseObject;
    
    if (filterType == 1)
    {
        parseObject = [memberUsers objectAtIndex:indexPath.row];
    }
    else if (filterType == 2)
    {
        parseObject = [trialUsers objectAtIndex:indexPath.row];
    }
    else
    {
        //imageObject = [self.imageFileArray objectAtIndex:indexPath.row];
        parseObject = [self.browseArray objectAtIndex:indexPath.row];
    }

    PFUser *userObject = [parseObject objectForKey:kUserKey];
    
    float ratingFloat = [[parseObject objectForKey:kCurrentRatingKey] floatValue];
    if (ratingFloat > 0)
    {
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
        [numberFormatter setMaximumFractionDigits:1];
        [numberFormatter setMinimumFractionDigits:1];
        
        NSString *ratingString = [NSString stringWithFormat:@"%@ | %@ ratings",[numberFormatter stringFromNumber:[parseObject objectForKey:kCurrentRatingKey]],[[parseObject objectForKey:kNumRatingsKey] stringValue]];
        
        cell.ratingLabel.text = ratingString;
    }
    
    int i;
    for (i = 0; i < [self.imageFileArray count]; i++)
    {
        PFObject *imageObject = [self.imageFileArray objectAtIndex:i];
        PFFile *imageFile = [imageObject objectForKey:@"image"];
        PFUser *imageUser = [imageObject objectForKey:kUserKey];
        if ([imageUser.objectId isEqual:userObject.objectId])
        {
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    cell.image.image = [UIImage imageWithData:data];
                }
            }];
        }
    }

    if ([[userObject objectForKey:kStatusKey] isEqualToString:kAdmitted])
    {
        NSString *usernameString = userObject.username;
        cell.username.text = usernameString;
        cell.trialLabel.text = @"";
        
        return cell;
    }
    else if ([[userObject objectForKey:kStatusKey] isEqualToString:kTrial])
    {
        NSDate *createDate;
        createDate = [parseObject createdAt];
        
        int trialNum;
        NSDate *today = [NSDate date];
        NSTimeInterval trial = [today timeIntervalSinceDate:createDate];
        trial = trial/86400;
        trial = floor(trial);
        trialNum = (int)roundf(trial);
        trialNum = 7 - trialNum;
        
        NSString *usernameString = userObject.username;
        cell.username.text = usernameString;
        cell.trialLabel.text = [NSString stringWithFormat:@"Trial | %d days left", trialNum];
        
        return cell;
    }
    else
    {
        return cell;
    }
    
    /*
     PFObject *imageObject;
     
     if (isFiltered)
     {
     imageObject = [filteredUsers objectAtIndex:indexPath.row];
     }
     else
     {
     //imageObject = [self.imageFileArray objectAtIndex:indexPath.row];
     imageObject = [self.browseArray objectAtIndex:indexPath.row];
     }
     //NSLog(@"%@", imageObject);
     PFFile *imageFile = [imageObject objectForKey:@"thumbnail"];
     PFUser *userObject = [imageObject objectForKey:@"user"];
     
     //tableView.backgroundColor = [UIColor clearColor];
     //cell.backgroundColor = [UIColor clearColor];
     
     int i;
     for (i = 0; i < [ratingArray count]; i++)
     {
     PFObject *ratingObject = [ratingArray objectAtIndex:i];
     PFUser *ratingUser = [ratingObject objectForKey:kUserKey];
     float ratingFloat = [[ratingObject objectForKey:@"currentRating"] floatValue];
     
     if ([ratingUser.objectId isEqual:userObject.objectId])
     {
     if (ratingFloat > 0)
     {
     NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc]init];
     [numberFormatter setMaximumFractionDigits:1];
     [numberFormatter setMinimumFractionDigits:1];
     NSString *ratingString = [NSString stringWithFormat:@"%@ | %@ ratings",[numberFormatter stringFromNumber:[ratingObject objectForKey:@"currentRating"]],[[ratingObject objectForKey:@"numRatings"] stringValue]];
     cell.ratingLabel.text = ratingString;
     break;
     }
     }
     }
     
     if ([[userObject objectForKey:kStatusKey] isEqualToString:kAdmitted])
     {
     [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
     if (!error)
     {
     cell.image.image = [UIImage imageWithData:data];
     }
     }];
     
     NSString *usernameString = userObject.username;
     cell.username.text = usernameString;
     cell.trialLabel.text = @"";
     
     //NSLog(@"%@", usernameString);
     
     return cell;
     }
     else if ([[userObject objectForKey:kStatusKey] isEqualToString:kTrial])
     {
     NSDate *createDate;
     createDate = [imageObject createdAt];
     
     int trialNum;
     NSDate *today = [NSDate date];
     NSTimeInterval trial = [today timeIntervalSinceDate:createDate];
     trial = trial/86400;
     trial = floor(trial);
     trialNum = (int)roundf(trial);
     trialNum = 7 - trialNum;
     
     [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
     if (!error)
     {
     cell.image.image = [UIImage imageWithData:data];
     }
     }];
     
     NSString *usernameString = userObject.username;
     cell.username.text = usernameString;
     cell.trialLabel.text = [NSString stringWithFormat:@"Trial | %d days left", trialNum];
     
     //NSLog(@"%@", usernameString);
     
     return cell;
     }
     else
     {
     return cell;
     }
     
     
    */
    
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        return 338;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"viewProfileSegue" sender:indexPath];
    [browseCollection deselectRowAtIndexPath:indexPath animated:YES];
}


- (IBAction)userSelection:(id)sender
{
    if (userViewSelection.selectedSegmentIndex == 1)
    {
        [userViewSelection setImage:[[UIImage imageNamed:@"allusers.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [userViewSelection setImage:[[UIImage imageNamed:@"membersselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [userViewSelection setImage:[[UIImage imageNamed:@"trialusers.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Viewed Member Users"];
        [mixpanel flush];
        
        memberUsers = [[NSMutableArray alloc]init];
        filterType = 1;
        
        for (PFObject *object in self.browseArray)
        {
            PFUser *userObject = [object objectForKey:@"user"];
            NSString *userStatus = [userObject objectForKey:kStatusKey];
            
            if ([userStatus isEqualToString:kAdmitted])
            {
                [memberUsers addObject:object];
            }
        }
        
    }
    else if (userViewSelection.selectedSegmentIndex == 2)
    {
        [userViewSelection setImage:[[UIImage imageNamed:@"allusers.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [userViewSelection setImage:[[UIImage imageNamed:@"members.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [userViewSelection setImage:[[UIImage imageNamed:@"trialusersselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Viewed Trial Users"];
        [mixpanel flush];
        
        trialUsers = [[NSMutableArray alloc]init];
        filterType = 2;
        
        for (PFObject *object in self.browseArray)
        {
            PFUser *userObject = [object objectForKey:@"user"];
            NSString *userStatus = [userObject objectForKey:kStatusKey];
            
            if ([userStatus isEqualToString:kTrial])
            {
                [trialUsers addObject:object];
            }
        }
        
    }
    else
    {
        [userViewSelection setImage:[[UIImage imageNamed:@"allusersselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [userViewSelection setImage:[[UIImage imageNamed:@"members.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [userViewSelection setImage:[[UIImage imageNamed:@"trialusers.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
        
        filterType = 0;
        
    }
    
    [self.view setNeedsLayout];
    [browseCollection reloadData];
}

- (IBAction)filterAction:(id)sender
{
    [activityIndicator startAnimating];
    
    if (filterSelection.selectedSegmentIndex == 1)
    {
        [filterSelection setImage:[[UIImage imageNamed:@"joindate.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [filterSelection setImage:[[UIImage imageNamed:@"ratingselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [filterSelection setImage:[[UIImage imageNamed:@"numratings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
    }
    else if (filterSelection.selectedSegmentIndex == 2)
    {
        [filterSelection setImage:[[UIImage imageNamed:@"joindate.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [filterSelection setImage:[[UIImage imageNamed:@"rating.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [filterSelection setImage:[[UIImage imageNamed:@"numratingsselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
    }
    else
    {
        [filterSelection setImage:[[UIImage imageNamed:@"joindateselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:0];
        [filterSelection setImage:[[UIImage imageNamed:@"rating.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:1];
        [filterSelection setImage:[[UIImage imageNamed:@"numratings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] forSegmentAtIndex:2];
    }
    [self.imageFileArray removeAllObjects];
    [self.browseArray removeAllObjects];
    [trialUsers removeAllObjects];
    [memberUsers removeAllObjects];
    [self.ratingArray removeAllObjects];
    max = 0;
    [browseCollection reloadData];
    
    [self.view setNeedsLayout];
    
    [self queryParse];
}

- (IBAction)moreUsers:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"More Users"];
    [mixpanel flush];
    
    NSLog(@"%lu", (unsigned long)[self.ratingArray count]);
    
    int temp = limitAdder + 1;
    
    if (limitAdder >= [self.ratingArray count] || temp == [self.ratingArray count])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You've reached the end of the list" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Okay", nil];
        [alert show];
    }
    else if (height == 480 && (limitAdder + 4) < [self.ratingArray count])
    {
        max = limitAdder + 4;
        limitAdder++;
    }
    else if ((limitAdder + 5) < [self.ratingArray count])
    {
        max = limitAdder + 5;
        limitAdder++;
    }
    else
    {
        max = (int)[self.ratingArray count];
        limitAdder++;
    }
    
    while (limitAdder < max)
    {
        [self.browseArray addObject:self.ratingArray[limitAdder]];
        limitAdder++;
    }
    
    [self userSelection:self];
    //[browseCollection reloadData];
    //[self queryParse];
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    [refreshControl endRefreshing];
    
    [self.imageFileArray removeAllObjects];
    [self.browseArray removeAllObjects];
    [trialUsers removeAllObjects];
    [memberUsers removeAllObjects];
    [self.ratingArray removeAllObjects];
    max = 0;
    [browseCollection reloadData];
    [self queryParse];
}

-(void)viewDidLayoutSubviews
{
    [filterSelection setFrame:CGRectMake(self.filterSelection.frame.origin.x, self.filterSelection.frame.origin.y, filterSelection.frame.size.width, 35)];
    
    [userViewSelection setFrame:CGRectMake(self.userViewSelection.frame.origin.x, self.userViewSelection.frame.origin.y, userViewSelection.frame.size.width, 35)];
}

-(void) setUpUserSegmentedControl
{
    //Add clear color to mask any bits of a selection state that the object might show around the images
    userViewSelection.tintColor = [UIColor clearColor];
    [userViewSelection setFrame:CGRectMake(self.userViewSelection.frame.origin.x, self.userViewSelection.frame.origin.y, userViewSelection.frame.size.width, 35)];
    
    UIImage *allUsers;
    UIImage *members;
    UIImage *trials;
    UIImage *separator;
    
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)])
    {
        allUsers = [[UIImage imageNamed:@"allusersselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        members = [[UIImage imageNamed:@"members.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        trials = [[UIImage imageNamed:@"trialusers.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        separator = [[UIImage imageNamed:@"border.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
    }
    else
    {
        allUsers = [UIImage imageNamed:@"allusersselected.png"];
        members = [UIImage imageNamed:@"members.png"];
        trials = [UIImage imageNamed:@"trialusers.png"];
        separator = [UIImage imageNamed:@"border.png"];
    }
    
    
    [self.userViewSelection setImage:allUsers forSegmentAtIndex:0];
    [self.userViewSelection setImage:members forSegmentAtIndex:1];
    [self.userViewSelection setImage:trials forSegmentAtIndex:2];
    [self.userViewSelection setDividerImage:separator forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

-(void) setUpSegmentedControlFilters
{
    //Add clear color to mask any bits of a selection state that the object might show around the images
    filterSelection.tintColor = [UIColor clearColor];
    [filterSelection setFrame:CGRectMake(self.filterSelection.frame.origin.x, self.filterSelection.frame.origin.y, filterSelection.frame.size.width, 35)];
    
    UIImage *joinDate;
    UIImage *rating;
    UIImage *numRatings;
    UIImage *separator;
    
    if ([UIImage instancesRespondToSelector:@selector(imageWithRenderingMode:)])
    {
        joinDate = [[UIImage imageNamed:@"joindateselected.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        rating = [[UIImage imageNamed:@"rating.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        numRatings = [[UIImage imageNamed:@"numratings.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        separator = [[UIImage imageNamed:@"border.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
    }
    else
    {
        joinDate = [UIImage imageNamed:@"joindateselected.png"];
        rating = [UIImage imageNamed:@"rating.png"];
        numRatings = [UIImage imageNamed:@"numratings.png"];
        separator = [UIImage imageNamed:@"border.png"];
    }
    
    
    [self.filterSelection setImage:joinDate forSegmentAtIndex:0];
    [self.filterSelection setImage:rating forSegmentAtIndex:1];
    [self.filterSelection setImage:numRatings forSegmentAtIndex:2];
    [self.filterSelection setDividerImage:separator forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        [self.view setNeedsLayout];
    }
}


@end
