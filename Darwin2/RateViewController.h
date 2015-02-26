//
//  RateViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/7/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Parse/Parse.h"

@interface RateViewController : UIViewController
{
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
    CLLocation *userLocation;
    int height;
    int flag;
    int rateActionFlag;
    int winkActionFlag;
}

@property (strong, nonatomic) PFUser *parseUser;
@property (strong, nonatomic) UIButton *menuBtn;
@property (strong, nonatomic) NSNumber *ratingNum;
@property (strong, nonatomic) NSNumber *currentRating;
@property (strong, nonatomic) NSArray *parseArray;
@property (strong, nonatomic) NSArray *winkArray;
@property (strong, nonatomic) NSArray *userWinkArray;
@property (strong, nonatomic) NSArray *ratingArray;
@property (strong, nonatomic) NSNumber *currentSliderValue;
@property (strong, nonatomic) IBOutlet UIImageView *cornerFlag;


@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *userImage;
@property (strong, nonatomic) IBOutlet UILabel *locationLabel;

@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;

- (IBAction)submit:(id)sender;
- (IBAction)wink:(id)sender;
- (IBAction)nextUser:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *winkButton;
@property (strong, nonatomic) IBOutlet UILabel *numRatings;

@property (strong, nonatomic) IBOutlet UILabel *currentRatingAvg;

@property (strong, nonatomic) IBOutlet UILabel *ratingNumber;
- (IBAction)sliderValueChanged:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *slider;



@end
