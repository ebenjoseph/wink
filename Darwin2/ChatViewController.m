//
//  ChatViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 5/30/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "ChatViewController.h"
#import "RateViewController.h"

@interface ChatViewController ()

@property (strong, nonatomic) PFUser *withUser;
@property (strong, nonatomic) PFUser *currentUser;

@property (strong, nonatomic) NSTimer *chatsTimer;
@property (nonatomic) BOOL initialLoadComplete;

@property (strong, nonatomic) NSMutableArray *chats;
@property (strong, nonatomic) NSMutableArray *withUserArray;

@end

@implementation ChatViewController
@synthesize parseUser, selfImage, userImage, chatRoom, profileImage;

-(NSMutableArray *)chats
{
    if (!_chats)
    {
        _chats = [[NSMutableArray alloc] init];
    }
    return _chats;
}

-(NSMutableArray *)withUserArray
{
    if (!_withUserArray)
    {
        _withUserArray = [[NSMutableArray alloc] init];
    }
    return _withUserArray;
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
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    
    flag = 0;
    inChatBool = [NSNumber numberWithBool:NO];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened Chatroom"];
    [mixpanel flush];
    
    self.delegate = self;
    self.dataSource = self;
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //NSLog(@"Chatroom: %@", _chatRoom);
    
    [[JSBubbleView appearance] setFont:[UIFont fontWithName:@"HelveticaNeue" size:17.0f]];
    
    //ADD INTERESTING FACT
    
    self.messageInputView.textView.placeHolder = @"New Message";
    [self setBackgroundColor:[UIColor whiteColor]];
    
    self.currentUser = [PFUser currentUser];
    self.withUser = parseUser;
    
    [self otherUserInChatQuery];
    
    /*
    PFUser *testUser1 = self.chatRoom[@"user1"];
    if ([testUser1.objectId isEqual:self.currentUser.objectId])
    {
        self.withUser = self.chatRoom[@"user2"];
    }
    else
    {
        self.withUser = self.chatRoom[@"user1"];
    }
     */
    
    UIButton *titleButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, 10)];
    [titleButton addTarget:self action:@selector(userTitlePress:) forControlEvents:UIControlEventTouchUpInside];
    //[titleButton setTitle:self.withUser.username forState:UIControlStateNormal];
    titleButton.center = self.navigationController.navigationBar.center;
    titleButton.center = CGPointMake(titleButton.center.x, self.navigationController.navigationBar.frame.size.height/2);
    [self.navigationController.navigationBar addSubview:titleButton];

    self.title = self.withUser.username;
    self.initialLoadComplete = NO;
    
    [self checkForNewChats];
    
    self.chatsTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(checkForNewChats) userInfo:nil repeats:YES];
    
}

- (void)userTitlePress:(id)sender
{
    [self performSegueWithIdentifier:@"viewProfileFromChat" sender:nil];
}

- (void)goBack:(id)sender
{
    [self.view removeFromSuperview];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Viewed User from Chat"];
    [mixpanel flush];
    
    RateViewController *rvc = [segue destinationViewController];
    
    rvc.userImage = profileImage;
    rvc.parseUser = self.withUser;
}

- (void)otherUserInChatQuery
{
    PFQuery *query = [PFQuery queryWithClassName:@"_User"];
    [query whereKey:@"username" equalTo:self.withUser.username];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error)
        {
            self.withUserArray = [objects mutableCopy];
            userInChat = self.withUserArray[0];
            inChatBool = [userInChat objectForKey:@"inChatRoom"];
            flag = 1;
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.chatsTimer invalidate];
    self.chatsTimer = nil;
    
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"inChatRoom"];
    [[PFUser currentUser] saveInBackground];
}

- (IBAction)screenTap:(id)sender
{
    [self.view endEditing:YES];
}

#pragma mark - TableView DataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return ([self.chats count]);
}

#pragma mark - TableView Delegate


-(void)didSendText:(NSString *)text
{
    if (text.length != 0)
    {
        PFObject *chat = [PFObject objectWithClassName:kChatKey];
        [chat setObject:self.chatRoom forKey:kChatroomKey];
        [chat setObject:self.currentUser forKey:kFromUserKey];
        [chat setObject:self.withUser forKey:kToUserKey];
        [chat setObject:text forKey:kTextKey];
        [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error)
            {
                [self.chats addObject:chat];
                [JSMessageSoundEffect playMessageSentSound];
                [self.tableView reloadData];
                [self finishSend];
                [self scrollToBottomAnimated:YES];
            }
        }];
        
        //NSLog(@"%@", chatRoom);
        [chatRoom setObject:text forKey:@"lastChat"];
        [chatRoom saveInBackground];
    }
    
    //NOTIFICATIONS
    
    //Check to see if other user is in chat
    if (flag)
    {
        userInChat = self.withUserArray[0];
        inChatBool = [userInChat objectForKey:@"inChatRoom"];
    }
    
    if (inChatBool == [NSNumber numberWithBool:NO])
    {
        PFQuery *pushQuery = [PFInstallation query];
        NSString *channelID = [NSString stringWithFormat:@"w%@-%@", self.withUser.objectId, self.currentUser.objectId];
        [pushQuery whereKey:kUserKey equalTo:self.currentUser];
        //[pushQuery whereKey:kChannelsKey equalTo:channelID];
        NSString *fullPushText = [NSString stringWithFormat:@"%@: %@", self.currentUser.username, text];
        
        NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                              fullPushText, @"alert",
                              @"Increment", @"badge",
                              nil];
        PFPush *push = [[PFPush alloc] init];
        
        //TESTING
        //[push setChannels:[NSArray arrayWithObjects:self.currentUser.username, nil]];
        
        [push setChannels:[NSArray arrayWithObjects:channelID, nil]];
        [push setData:data];
        [push sendPushInBackground];
    }

}


-(JSBubbleMessageType)messageTypeForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId])
    {
        return JSBubbleMessageTypeOutgoing;
    }
    else
    {
        return JSBubbleMessageTypeIncoming;
    }
}

-(UIImageView *)bubbleImageViewWithType:(JSBubbleMessageType)type forRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId])
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleBlueColor]];
    }
    else
    {
        return [JSBubbleImageViewFactory bubbleImageViewForType:type color:[UIColor js_bubbleLightGrayColor]];
    }
}

- (JSMessagesViewTimestampPolicy)timestampPolicy
{
    return JSMessagesViewTimestampPolicyAll;
}

-(JSMessagesViewAvatarPolicy)avatarPolicy
{
    return JSMessagesViewAvatarPolicyAll;
}

-(JSMessagesViewSubtitlePolicy)subtitlePolicy
{
    return JSMessagesViewSubtitlePolicyNone;
}

-(JSMessageInputViewStyle)inputViewStyle
{
    return JSMessageInputViewStyleFlat;
}

#pragma mark - Messages View Delegate OPTIONAL



-(void)configureCell:(JSBubbleMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell messageType] == JSBubbleMessageTypeOutgoing)
    {
        cell.bubbleView.textView.textColor = [UIColor whiteColor];
    }
}

-(BOOL)shouldPreventScrollToBottomWhileUserScrolling
{
    return YES;
}

#pragma mark - Messages View Data Source REQUIRED

-(NSString *)textForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *chat = self.chats[indexPath.row];
    NSString *message = chat[kTextKey];
    return message;
}

-(NSDate *)timestampForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PFObject *dateObject = _chats[indexPath.row];
    NSDate *newDate = [dateObject createdAt];
    
    if (indexPath.row == 0)
    {
        return newDate;
    }
    else
    {
        PFObject *previousDateObject = _chats[(indexPath.row -1)];
        
        NSDate *previousDate = [previousDateObject createdAt];
        unsigned int unitFlags = NSMinuteCalendarUnit;
        NSCalendar *calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *conversionInfo = [calendar components:unitFlags fromDate:previousDate toDate:newDate options:0];
        
        if ([conversionInfo minute] > 5)
        {
            return newDate;
        }
        else
        {
            return nil;
        }
    }
    
    return nil;
}

-(UIImageView *)avatarImageViewForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PFObject *chat = self.chats[indexPath.row];
    PFUser *testFromUser = chat[kFromUserKey];
    
    if ([testFromUser.objectId isEqual:self.currentUser.objectId])
    {
        return [[UIImageView alloc]initWithImage:selfImage];
    }
    else
    {
        return [[UIImageView alloc]initWithImage:userImage];
    }
    
    return nil;
}

-(NSString *)subtitleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - Helper Methods

- (void)checkForNewChats
{
    long oldChatCount = [self.chats count];
    //NSLog(@"%ld", oldChatCount);
    
    PFQuery *queryForChats = [PFQuery queryWithClassName:kChatKey];
    [queryForChats whereKey:kChatroomKey equalTo:self.chatRoom];
    [queryForChats orderByAscending:@"createdAt"];
    [queryForChats includeKey:@"createdAt"];
    queryForChats.limit = 50;
    
    
    [queryForChats countObjectsInBackgroundWithBlock:^(int number, NSError *error) {
        if (!error)
        {
            int skip = 0;
            if (number >= 50)
            {
                skip = number - 50;
            }
            queryForChats.skip = skip;
            
            [queryForChats findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (!error)
                {
                    if (self.initialLoadComplete == NO || oldChatCount != [objects count])
                    {
                        self.chats = [objects mutableCopy];
                        [self.tableView reloadData];
                        
                        if (self.initialLoadComplete == YES)
                        {
                            [JSMessageSoundEffect playMessageReceivedSound];
                        }
                        
                        self.initialLoadComplete = YES;
                        [self scrollToBottomAnimated:YES];
                    }
                }
            }];
        }
    }];
    
    //Also check to see if the other user is in the chat room with you
    if ([self.withUserArray count] == 1)
    {
        flag = 0;
        [self.withUserArray removeObjectAtIndex:0];
    }
    
    [self otherUserInChatQuery];
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

@end
