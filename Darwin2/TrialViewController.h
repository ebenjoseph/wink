//
//  TrialViewController.h
//  Wink
//
//  Created by Eli Ben-Joseph on 9/22/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TrialViewController : UIViewController
{
    int rateActionFlag;
    int height;
    int flag;
    int userCounter;
    BOOL noUsers;
    
    CLGeocoder *geocoder;
    CLLocation *userLocation;
    CLPlacemark *placemark;
    PFUser *parseUser;
    
    UIActivityIndicatorView *activityIndicator;
    
    NSArray *parseArray;
    NSArray *ratingArray;
    
    NSNumber *ratingNum;
    NSNumber *currentSliderValue;
    NSNumber *currentRating;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submit:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *numRatings;

@property (strong, nonatomic) IBOutlet UILabel *currentRatingAvg;

@property (strong, nonatomic) IBOutlet UILabel *ratingNumber;
- (IBAction)sliderValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UIImageView *cornerFlag;

@end
