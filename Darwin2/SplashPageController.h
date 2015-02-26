//
//  SplashPageController.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/18/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProfileViewController.h"

//@protocol passData <NSObject>

//-(void) setImage:(UIImage*)delegateUserImage;

//@end


@interface SplashPageController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>{
    
    ProfileViewController *pvc;
    
    IBOutlet UISegmentedControl *sc;
    IBOutlet UIImageView *imageView;
    UIImagePickerController *picker2;
    
    IBOutlet UIButton *reselectButton;
    
    int reselectFlag;
    
}

//@property (retain)id <passData> delegate;
@property BOOL imageChosen;
@property (strong, nonatomic) UIImage *userImage;
- (IBAction)camera;
- (IBAction)reselect;
- (IBAction)screentap;
- (IBAction)goToProfile:(id)sender;

- (void)setObject:(id)obj forKey:(id)key;

@end
