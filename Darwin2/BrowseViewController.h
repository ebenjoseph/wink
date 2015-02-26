//
//  BrowseViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/24/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseViewCell.h"
#import "Parse/Parse.h"

@interface BrowseViewController : UIViewController
{
    NSArray *usernameArray;
    NSMutableArray *imagesArray;
    NSMutableArray *trialUsers;
    NSMutableArray *memberUsers;
    int limitAdder;
    int height;
    int max;
    
    UIActivityIndicatorView *activityIndicator;
    
    UIRefreshControl *refreshControl;
    
    NSString *sex;
    NSString *seeking;
    
    int filterType;
}

@property (strong, nonatomic) UIButton *menuBtn;
@property (retain, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UISegmentedControl *userViewSelection;
@property (strong, nonatomic) IBOutlet UISegmentedControl *filterSelection;
@property (strong, nonatomic) IBOutlet UITableView *browseCollection;
- (IBAction)userSelection:(id)sender;
- (IBAction)moreUsers:(id)sender;
//- (IBAction)swipeDown:(id)sender;
- (IBAction)filterAction:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *moreUsersButton;

@end
