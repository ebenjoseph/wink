//
//  WinksViewCell.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 6/2/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "WinksViewCell.h"

@implementation WinksViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)toProfile:(id)sender
{
}
@end
