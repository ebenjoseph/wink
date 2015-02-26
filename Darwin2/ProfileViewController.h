//
//  ProfileViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/19/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideViewController.h"
#import "Parse/Parse.h"

@interface ProfileViewController : UIViewController
{
    IBOutlet UIImageView *imageView;
    NSMutableArray *parseArray;
    PFObject *imageObject;
    NSMutableArray *parseRatingArray;
    PFObject *ratingObject;
    NSNumber *currentRating;
    NSNumber *numRatings;
    NSDate *createDate;
    UIRefreshControl *refreshControl;
    int trialNum;
    int height;
    int remainingCounts;
    UIActivityIndicatorView *activityIndicator;
    
    SlideViewController *svc;
}

//@property (retain, nonatomic) UIImageView *imageView;
@property (retain, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UILabel *currentRatingTitle;
@property (strong, nonatomic) UIButton *menuBtn;
@property (strong, nonatomic) IBOutlet UILabel *currentRatingLabel;
@property (strong, nonatomic) IBOutlet UILabel *daysLeft;
@property (strong, nonatomic) IBOutlet UILabel *daysLeftTitle;
@property (strong, nonatomic) IBOutlet UILabel *statusLabel;
@property (strong, nonatomic) IBOutlet UILabel *numRatingsLabel;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UILabel *statusTitle;
@property (strong, nonatomic) IBOutlet UILabel *ratingsReceivedTitle;


@end
