//
//  WinksViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 5/30/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "WinksViewController.h"
#import "ECSlidingViewController.h"
#import "MenuViewController.h"
#import "ChatViewController.h"
#import "CustomBadge.h"
#import "RateViewController.h"

@interface WinksViewController ()

@end

@implementation WinksViewController


@synthesize menuBtn, userImage, winksCollection;

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
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened Winks Page"];
    [mixpanel flush];
    
    kBadgeNumber = @"0";
    
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
    [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    [self queryParse];
    
    //NSArray *blankArray = [[NSArray alloc]initWithObjects: nil];
    //PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    //[currentInstallation setChannels:blankArray];
    //[currentInstallation saveInBackground];
    
    channels = [PFInstallation currentInstallation].channels;
    NSLog(@"%@", channels);
    
    //NSLog(@"Lat: %@ Long: %@", kUserLatitude, kUserLongitude);
    
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
    [winksCollection addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshInvoked:forState:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)queryParse
{
    
    PFQuery *queryForChatRoom = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoom whereKey:@"user1" equalTo:[PFUser currentUser]];
    PFQuery *queryForChatRoomInverse = [PFQuery queryWithClassName:@"ChatRoom"];
    [queryForChatRoomInverse whereKey:@"user2" equalTo:[PFUser currentUser]];
    
    PFQuery *combinedQuery = [PFQuery orQueryWithSubqueries:@[queryForChatRoom, queryForChatRoomInverse]];
    [combinedQuery includeKey:@"user1"];
    [combinedQuery includeKey:@"user2"];
    [combinedQuery orderByDescending:@"updatedAt"];
        
    PFQuery *imagesQuery = [PFQuery queryWithClassName:@"photo"];
    PFQuery *infoQuery = [PFQuery queryWithClassName:@"info"];
    
    [combinedQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            userChatsArray = [[NSMutableArray alloc]initWithArray:objects];
            userDisplayArray = [[NSMutableArray alloc]init];
            int i;
            for (i = 0; i < [userChatsArray count]; i++)
            {
                PFObject *object = userChatsArray[i];
                PFUser *user1 = [object objectForKey:@"user1"];
                PFUser *user2 = [object objectForKey:@"user2"];
                
                if ([user1.objectId isEqual:[PFUser currentUser].objectId])
                {
                    [userDisplayArray addObject:user2];
                }
                else
                {
                    [userDisplayArray addObject:user1];
                }
            }
            
            [infoQuery whereKey:kUserKey containedIn:userDisplayArray];
            [infoQuery includeKey:kUserKey];
            
            [infoQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    infoArray = [[NSMutableArray alloc]initWithArray:objects];
                    
                    NSMutableArray *tempArray = [[NSMutableArray alloc]initWithArray:userDisplayArray];
                    [tempArray addObject:[PFUser currentUser]];
                    
                    [imagesQuery whereKey:kUserKey containedIn:tempArray];
                    [imagesQuery includeKey:kUserKey];
                    
                    [imagesQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        if (!error)
                        {
                            imagesArray = [[NSMutableArray alloc]initWithArray:objects];
                            [winksCollection reloadData];
                            [activityIndicator stopAnimating];
                            
                            if (userChatsArray == nil || [userChatsArray count] == 0)
                            {
                                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have no mutual winks yet, please keep browsing!" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                                [alert show];
                            }
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath = sender;

    if ([[segue identifier] isEqualToString:@"chatSegue"])
    {
        ChatViewController *cvc = [segue destinationViewController];
        
        PFUser *userObject = [userDisplayArray objectAtIndex:indexPath.row];
        
        int i;
        for (i = 0; i < [imagesArray count]; i++)
        {
            PFObject *imageObject = imagesArray[i];
            PFUser *imageUser = [imageObject objectForKey:kUserKey];
            if ([imageUser.objectId isEqual:userObject.objectId])
            {
                PFFile *imageFile = [imageObject objectForKey:@"thumbnail"];
                PFFile *profileImage = [imageObject objectForKey:@"image"];
                
                [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error)
                    {
                        //NSLog(@"User Image: %@", data);
                        cvc.userImage = [UIImage imageWithData:data];
                    }
                    else
                    {
                        NSLog(@"Error: %@", error);
                    }
                }];
                
                [profileImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error)
                    {
                        cvc.profileImage = [UIImage imageWithData:data];
                    }
                }];
            }
            else if ([imageUser.objectId isEqual:[PFUser currentUser].objectId])
            {
                PFFile *imageFile2 = [imageObject objectForKey:@"thumbnail"];
                
                [imageFile2 getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                    if (!error)
                    {
                        cvc.selfImage = [UIImage imageWithData:data];
                    }
                }];
            }
        }
        
        cvc.parseUser = [userDisplayArray objectAtIndex:indexPath.row];
        cvc.chatRoom = [userChatsArray objectAtIndex:indexPath.row];
        
        //Notify server that current user is entering chat
        [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"inChatRoom"];
        [[PFUser currentUser] saveInBackground];
    }
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
    return [userDisplayArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"winksCell";
    WinksViewCell *cell = (WinksViewCell *)[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    //NSArray *tempArray = [[infoArray reverseObjectEnumerator] allObjects];
    
    PFUser *userObject = [userDisplayArray objectAtIndex:indexPath.row];
    //PFObject *infoObject = [infoArray objectAtIndex:indexPath.row];
    
    /* 
     
    BADGE SETUP (Finish when necessary)
     
    CustomBadge *badge = [CustomBadge customBadgeWithString:@"2"
												   withStringColor:[UIColor whiteColor]
													withInsetColor:[UIColor redColor]
													withBadgeFrame:NO
											   withBadgeFrameColor:[UIColor whiteColor]
														 withScale:1.0
													   withShining:NO];
    [badge setFrame:CGRectMake(100, 50, 20, 20)];
    UIGraphicsBeginImageContextWithOptions((badge.frame.size), FALSE, [[UIScreen mainScreen] scale]);
	[badge.layer renderInContext:UIGraphicsGetCurrentContext()];
	UIImage *badgeAsImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    [cell.badgeView setImage:badgeAsImage];
    
     */
     
    //Set up user images
    int i;
    for (i = 0; i < [imagesArray count]; i++)
    {
        PFObject *imageObject = imagesArray[i];
        PFUser *imageUser = [imageObject objectForKey:kUserKey];
        if ([imageUser.objectId isEqual:userObject.objectId])
        {
            PFFile *imageFile = [imageObject objectForKey:@"thumbnail"];
            
            [imageFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if (!error)
                {
                    cell.image.image = [UIImage imageWithData:data];
                }
            }];
        }
    }
    
    //Set up user facts
    int j;
    for (j = 0; j < [infoArray count]; j++)
    {
        PFObject *infoObject = infoArray[j];
        PFUser *infoUser = [infoObject objectForKey:kUserKey];
        if ([infoUser.objectId isEqual:userObject.objectId])
        {
            NSString *factString = [infoObject objectForKey:@"fact"];
            
            //Remove space at end of fact if present
            if ([[factString substringFromIndex:([factString length]-1)] isEqualToString:@" "])
            {
                factString = [factString substringToIndex:([factString length]-1)];
            }
            
            cell.fact.text = [NSString stringWithFormat:@"\"I %@\"", factString];
        }
    }
    
    //Set up last chat and timestamp
    PFObject *chatObject = [userChatsArray objectAtIndex:indexPath.row];
    lastChat = [chatObject objectForKey:@"lastChat"];
    lastTimestamp = chatObject.updatedAt;
    if (lastChat.length != 0)
    {
        cell.lastChat.text = lastChat;

        NSDate *today = [NSDate date];
        NSTimeInterval interval = [today timeIntervalSinceDate:lastTimestamp];
        interval = interval/86400;
        interval = floor(interval);
        interval = (int)roundf(interval);
        
        
        if (interval >= 1)
        {
            cell.timestampLabel.text = [NSDateFormatter localizedStringFromDate:lastTimestamp dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterNoStyle];
        }
        else
        {
            cell.timestampLabel.text = [NSDateFormatter localizedStringFromDate:lastTimestamp dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        }
    }
    else
    {
        cell.lastChat.text = @"";
        cell.timestampLabel.text = @"";
    }
    
    //Set up sub-buttons
    cell.leftUtilityButtons = [self leftButtons];
    cell.delegate = self;
    
    //PFUser *userObject = [imageObject objectForKey:@"user"];
    
    NSString *usernameString = userObject.username;
    
    cell.username.text = usernameString;
    
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"chatSegue" sender:indexPath];
    
    [winksCollection deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void) refreshInvoked:(id)sender forState:(UIControlState)state
{
    [refreshControl endRefreshing];
    [userDisplayArray removeAllObjects];
    [self queryParse];
}

- (NSArray *)leftButtons
{
    NSMutableArray *leftUtilityButtons = [NSMutableArray new];

    [leftUtilityButtons sw_addUtilityButtonWithColor:
     [UIColor colorWithRed:1.0f green:0.231f blue:0.188 alpha:1.0f]
                                                title:@"Block"];
    
    return leftUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index)
    {
        case 0:
        {
            // Block button was pressed
            deletedIndexPath = [winksCollection indexPathForCell:cell];
            deletedChat = [userChatsArray objectAtIndex:deletedIndexPath.row];
            PFUser *deletedUser = [userDisplayArray objectAtIndex:deletedIndexPath.row];
            NSString *warningString = [NSString stringWithFormat:@"Are you sure you want to block %@?",deletedUser.username];
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:warningString message:nil delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Yes", nil];
            [alert show];
           
            break;
        }
        default:
            break;
    }
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [deletedChat deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                [userDisplayArray removeObjectAtIndex:deletedIndexPath.row];
                [winksCollection deleteRowsAtIndexPaths:@[deletedIndexPath]
                                       withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}

#pragma mark - Helper Methods



@end

