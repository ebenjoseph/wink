//
//  WinksViewCell.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 6/2/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WinksViewCell : SWTableViewCell

@property (strong, nonatomic) IBOutlet UIView *imageCell;
@property (strong, nonatomic) IBOutlet UIImageView *image;
@property (strong, nonatomic) IBOutlet UILabel *username;
@property (strong, nonatomic) IBOutlet UILabel *fact;
@property (strong, nonatomic) IBOutlet UILabel *lastChat;
@property (strong, nonatomic) IBOutlet UILabel *timestampLabel;
@property (strong, nonatomic) IBOutlet UIImageView *badgeView;

@end
