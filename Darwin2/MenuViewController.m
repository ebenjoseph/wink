//
//  MenuViewController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/25/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "MenuViewController.h"
#import "ECSlidingViewController.h"

@interface MenuViewController ()

@property (strong, nonatomic) NSArray *menu;

@end

@implementation MenuViewController

@synthesize menu, menuCollection;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //UIEdgeInsets inset = UIEdgeInsetsMake(20, 0, 0, 0);
    //self.tableView.contentInset = inset;
    
    NSString *winks;
    
    if ([kBadgeNumber intValue] == 0)
    {
        winks = @"Winks";
    }
    else
    {
        winks = [NSString stringWithFormat:@"Winks (%@)", kBadgeNumber];
    }
    
    self.menu = [NSArray arrayWithObjects:@"Profile", @"Rate Trial Users", @"Browse Members", winks, @"Logout", nil];
    
    [self.slidingViewController setAnchorRightRevealAmount:200.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.menu count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Here");
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier;
    //Winks exception
    
    switch (indexPath.row)
    {
        case 1:
            identifier = @"Trial";
            break;
        case 2:
            identifier = @"Browse";
            break;
        case 3:
            identifier = @"Winks";
            self.menu = [NSArray arrayWithObjects:@"Profile", @"Rate Trial Users", @"Browse Members", @"Winks", @"Logout", nil];
            [menuCollection reloadData];
            break;
        default:
            identifier = [NSString stringWithFormat:@"%@", [self.menu objectAtIndex:indexPath.row]];
            break;
    }
    
    NSString *winks;
    
    if ([kBadgeNumber intValue] == 0)
    {
        winks = @"Winks";
    }
    else
    {
        winks = [NSString stringWithFormat:@"Winks (%@)", kBadgeNumber];
    }
    
    self.menu = [NSArray arrayWithObjects:@"Profile", @"Rate Trial Users", @"Browse Members", winks, @"Logout", nil];
    [menuCollection reloadData];
    
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
    
    
}

@end
