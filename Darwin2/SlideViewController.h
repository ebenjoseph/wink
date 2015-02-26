//
//  SlideViewController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/24/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "ECSlidingViewController.h"
#import "Parse/Parse.h"

@interface SlideViewController : ECSlidingViewController
{
    PFObject *parseObject;
    NSString *sex;
    NSString *seeking;
}

@property (retain, nonatomic) UIImage *userImage;
@property (strong, nonatomic) UIButton *menuBtn;

@end
