//
//  LogoutViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/17/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "LogoutViewController.h"
#import "ViewController.h"

@interface LogoutViewController ()

@end

@implementation LogoutViewController

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
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Logout"];
    [mixpanel flush];
    
    //HACK - fix me!
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"inChatRoom"];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error)
        {
            [PFUser logOut];
            ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"one"];
            [self.navigationController popViewControllerAnimated:NO];
            [self presentViewController:vc animated:NO completion:nil];
        }
    }];
    
    
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
