//
//  BrowseViewCell.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/7/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowseViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *imageCell;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *trialLabel;
@property (strong, nonatomic) IBOutlet UILabel *ratingLabel;
@property (strong, nonatomic) IBOutlet UIView *cellView;



@end
