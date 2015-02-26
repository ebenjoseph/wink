//
//  BrowseViewCell.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/7/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "BrowseViewCell.h"

@implementation BrowseViewCell

@synthesize image, cellView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        cellView.layer.cornerRadius = 2;
        cellView.layer.shadowColor = [UIColor blackColor].CGColor;
        cellView.layer.shadowOffset = CGSizeMake(0, 1);
        cellView.layer.shadowOpacity = 0.5;
        cellView.layer.shadowRadius = 2.0;
        
        [self addSubview:cellView];
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (IBAction)viewTapped:(UITapGestureRecognizer *)sender
{
    NSLog(@"Open Profile View");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
