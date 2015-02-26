//
//  ChatViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 5/30/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "JSMessagesViewController.h"

@interface ChatViewController : JSMessagesViewController <JSMessagesViewDataSource, JSMessagesViewDelegate>
{
    PFUser *userInChat;
    int flag;
    NSNumber *inChatBool;
}

@property (strong, nonatomic) PFObject *chatRoom;
@property (strong, nonatomic) PFUser *parseUser;
@property (strong, nonatomic) UIImage *selfImage;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIImage *profileImage;


- (IBAction)screenTap:(id)sender;

@end
