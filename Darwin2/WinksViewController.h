//
//  WinksViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 5/30/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "ViewController.h"
#import "WinksViewCell.h"

@interface WinksViewController : UIViewController
{
    NSArray *imageFileArray;
    NSArray *usernameArray;
    NSMutableArray *userChatsArray;
    NSMutableArray *userDisplayArray;
    NSMutableArray *imagesArray;
    NSMutableArray *infoArray;
    NSArray *channels;
    UIImage *baseUserImage;
    UIImage *baseSelfImage;
    
    UIRefreshControl *refreshControl;
    
    UIActivityIndicatorView *activityIndicator;
    
    NSString *sex;
    NSString *seeking;
    NSString *lastChat;
    NSDate *lastTimestamp;
    
    PFObject *deletedChat;
    NSIndexPath *deletedIndexPath;
}

@property (strong, nonatomic) UIButton *menuBtn;
@property (retain, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UITableView *winksCollection;

@end
