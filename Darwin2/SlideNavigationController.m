//
//  SlideNavigationController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 6/25/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "SlideNavigationController.h"

@interface SlideNavigationController ()

@end

@implementation SlideNavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationBar.barTintColor = [UIColor colorWithRed:222.0 green:230.0 blue:238.0 alpha:1.0];
    self.navigationBar.tintColor = nil;
    self.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
