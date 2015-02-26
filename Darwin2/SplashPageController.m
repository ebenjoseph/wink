//
//  SplashPageController.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/18/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "SplashPageController.h"
#import "SlideViewController.h"
#import <Parse/Parse.h>
#import "UIImage+ResizeAdditions.h"
#import "UserInfoViewController.h"
#import "TransitionAnimator.h"

@interface SplashPageController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) PFFile *photoFile;
@property (nonatomic, strong) PFFile *thumbnailFile;
@property (nonatomic, assign) UIBackgroundTaskIdentifier fileUploadBackgroundTaskId;
@property (nonatomic, assign) UIBackgroundTaskIdentifier photoPostBackgroundTaskId;
@property (nonatomic,strong) UINavigationController *navController;
@end

@implementation SplashPageController
@synthesize userImage, navController;
@synthesize image, photoFile, thumbnailFile, fileUploadBackgroundTaskId, photoPostBackgroundTaskId;

- (IBAction)camera
{
    picker2 = [[UIImagePickerController alloc]init];
    picker2.delegate = self;
    
    if (sc.selectedSegmentIndex == 0)
    {
        [picker2 setSourceType:UIImagePickerControllerSourceTypeCamera];
    }
    else if (sc.selectedSegmentIndex == 1)
    {
        [picker2 setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    }
    
    picker2.allowsEditing = YES;
    //picker2.showsCameraControls = YES;
    picker2.delegate = self;

    [self presentViewController:picker2 animated:(YES) completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.image = [info objectForKey:UIImagePickerControllerEditedImage];
    
    [imageView setImage:self.image];
    reselectFlag = 0;
    
    //pvc.userImage = self.image;
    
    self.imageChosen = YES;
    reselectButton.hidden = NO;
    
    self.fileUploadBackgroundTaskId = UIBackgroundTaskInvalid;
    self.photoPostBackgroundTaskId = UIBackgroundTaskInvalid;
    
    [self dismissViewControllerAnimated:NO completion:nil];
    
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)reselect
{
    sc.selectedSegmentIndex = -1;
    UIImage *imageNull = NULL;
    [imageView setImage:imageNull];
    reselectButton.hidden = YES;
    reselectFlag = 1;
}

- (IBAction)screentap
{
    sc.selectedSegmentIndex = -1;
}

- (IBAction)goToProfile:(id)sender
{
    
    //svc.userImage = userImage;
    
    if (!self.imageChosen || reselectFlag) {
        
        BOOL segueShouldOccur = NO;
        if (!segueShouldOccur) {
            UIAlertView *notPermitted = [[UIAlertView alloc]
                                         initWithTitle:@"No Image Chosen"
                                         message:@"You Must Select an Image"
                                         delegate:nil
                                         cancelButtonTitle:@"Dismiss"
                                         otherButtonTitles:nil];
            [notPermitted show];
        }
    }
    else
    {
        //[self.view addSubview:pvc2.view];
        [self shouldUploadImage:self.image];
        [self doneButtonAction:(sender)];

    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*
    UIGraphicsBeginImageContext(self.view.frame.size);
    [[UIImage imageNamed:@"patternBG.jpg"] drawInRect:self.view.bounds];
    UIImage *bgimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
     */
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    reselectFlag = 0;
    
    sc.selectedSegmentIndex = -1;
    self.imageChosen = NO;
    reselectButton.hidden = YES;
    
    self.navController = [[UINavigationController alloc] init];

    [self shouldUploadImage:self.image];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ()

- (BOOL)shouldUploadImage:(UIImage *)anImage {
    //UIImage *resizedImage = [anImage resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(560.0f, 560.0f) interpolationQuality:kCGInterpolationHigh];
    //UIImage *resizedImage = [anImage thumbnailImage:320.0f transparentBorder:0.0f cornerRadius:0.0f interpolationQuality:kCGInterpolationDefault];
    UIImage *thumbnailImage = [anImage thumbnailImage:110.0f transparentBorder:0.0f cornerRadius:3.0f interpolationQuality:kCGInterpolationDefault];
    
    NSData *imageData = UIImagePNGRepresentation(anImage);
    NSData *thumbnailImageData = UIImagePNGRepresentation(thumbnailImage);
    
    if (!imageData || !thumbnailImageData) {
        return NO;
    }
    
    self.photoFile = [PFFile fileWithData:imageData];
    self.thumbnailFile = [PFFile fileWithData:thumbnailImageData];
    
    // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
    self.fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
    }];
    
    [self.photoFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            [self.thumbnailFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
            }];
        } else {
            [[UIApplication sharedApplication] endBackgroundTask:self.fileUploadBackgroundTaskId];
        }
    }];
    
    
    
    return YES;
}


- (void)doneButtonAction:(id)sender
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure you want to use this photo?" message:@"Once your photo is chosen, you cannot change it throughout the entire trial period" delegate:self cancelButtonTitle:@"Back" otherButtonTitles:@"Yes", nil];
    [alert show];
    
    
    
    // Dismiss this screen
    //[self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    
    //SlideViewController *svc = [self.storyboard instantiateViewControllerWithIdentifier:@"Slide"];
    //[self presentViewController:svc animated:(YES) completion:nil];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0)
    {
        
    }
    if (buttonIndex == 1)
    {
        //Activity Indicator
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [activityIndicator setBackgroundColor:[UIColor grayColor]];
        [activityIndicator setAlpha:0.5];
        [activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityIndicator.center = self.view.center;
        activityIndicator.layer.cornerRadius = 3;
        [self.view addSubview:activityIndicator];
        [activityIndicator startAnimating];
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        
        // Make sure there were no errors creating the image files
        if (!self.photoFile || !self.thumbnailFile)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
            [alert show];
            return;
        }
        
        // both files have finished uploading
        
        // create a photo object
        PFObject *photo = [PFObject objectWithClassName:@"photo"];
        [photo setObject:[PFUser currentUser] forKey:kUserKey];
        [photo setObject:self.photoFile forKey:@"image"];
        [photo setObject:self.thumbnailFile forKey:kUserThumbnailKey];
        
        //Create a data object
        NSNumber *zeroNum = [NSNumber numberWithInt:0];
        PFObject *dataObject = [PFObject objectWithClassName:@"rating"];
        [dataObject setObject:[PFUser currentUser] forKey:kUserKey];
        [dataObject setObject:zeroNum forKey:kNumRatingsKey];
        [dataObject setObject:zeroNum forKey:kCurrentRatingKey];
        
        // photos are public, but may only be modified by the user who uploaded them
        PFACL *photoACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [photoACL setPublicReadAccess:YES];
        photo.ACL = photoACL;
        
        //making ratings editable
        PFACL *dataACL = [PFACL ACLWithUser:[PFUser currentUser]];
        [dataACL setPublicWriteAccess:YES];
        [dataACL setPublicReadAccess:YES];
        dataObject.ACL = dataACL;
        
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
        }];
        
        [dataObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded)
            {
                NSLog(@"Data Object Created");
                [photo setObject:dataObject forKey:@"rating"];
                
                // Save the Photo PFObject
                [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        [activityIndicator stopAnimating];
                        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                        
                        UIStoryboard *myStoryboard = self.storyboard;
                        UserInfoViewController *userInfo = [myStoryboard instantiateViewControllerWithIdentifier:@"UserInfo"];
                        userInfo.view.backgroundColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:.75];
                        userInfo.transitioningDelegate = self;
                        userInfo.modalPresentationStyle = UIModalPresentationCustom;
                        [self presentViewController:userInfo animated:YES completion:nil];
                        
                        /*
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Photo Added" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Set My Info", nil];
                        [alert show];
                        */
                        
                        //[self setAttributesForPhoto:photo raters:[NSArray array]];
                        
                        //[[NSNotificationCenter defaultCenter] postNotificationName:PAPTabBarControllerDidFinishEditingPhotoNotification object:photo];
                    } else {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't post your photo" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                        [alert show];
                    }
                    [[UIApplication sharedApplication] endBackgroundTask:self.photoPostBackgroundTaskId];
                }];
            }
            else
            {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Dismiss", nil];
                [alert show];
            }
        }];
    }
}

- (void)setAttributesForPhoto:(PFObject *)photo raters:(NSArray *)raters
{
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@([raters count]), @"raters", nil];
    [self setAttributes:attributes forPhoto:photo];
}

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo
{
    NSString *key = [self keyForPhoto:photo];
    [self setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user
{
    NSString *key = [self keyForUser:user];
    [self setObject:attributes forKey:key];
}

- (NSString *)keyForPhoto:(PFObject *)photo
{
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user
{
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

#pragma mark - UIViewControllerTransitioningDelegate

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    TransitionAnimator *animator = [[TransitionAnimator alloc] init];
    animator.presenting = YES;
    return animator;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    TransitionAnimator *animator = [[TransitionAnimator alloc]init];
    return  animator;
}


@end
