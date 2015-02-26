//
//  AppDelegate.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 3/18/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "SlideNavigationController.h"

@implementation AppDelegate

@synthesize userImage;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [Parse setApplicationId:@"oTlmfp3ZhRnW81I4u4fRdIU7GQ2m97TaSBO5WVDZ" clientKey:@"2X1G9OXar4C4neupBYJhJiLWSoYpFXSBYza2gQth"];
    
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    // If you are using Facebook, uncomment and add your FacebookAppID to your bundle's plist as
    // described here: https://developers.facebook.com/docs/getting-started/facebook-sdk-for-ios/
    // [PFFacebookUtils initializeFacebook];
    // ****************************************************************************
    
    [PFUser enableAutomaticUser];
    
    PFACL *defaultACL = [PFACL ACL];
    
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // Override point for customization after application launch.
    
    //self.window.rootViewController = self.viewController;
    //[self.window makeKeyAndVisible];
    
    //Set up push notifications
    [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge |
                                                    UIRemoteNotificationTypeAlert |
                                                    UIRemoteNotificationTypeSound];
    
    //Set up default preferences
    NSString *defaultPrefsFile = [[NSBundle mainBundle]pathForResource:@"defaultSettings" ofType:@"plist"];
    NSDictionary *defaultPreferences = [NSDictionary dictionaryWithContentsOfFile:defaultPrefsFile];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultPreferences];
    
    if (application.applicationState != UIApplicationStateBackground) {
        // Track an app open here if we launch with a push, unless
        // "content_available" was used to trigger a background push (introduced
        // in iOS 7). In that case, we skip tracking here to avoid double
        // counting the app-open.
        BOOL preBackgroundPush = ![application respondsToSelector:@selector(backgroundRefreshStatus)];
        BOOL oldPushHandlerOnly = ![self respondsToSelector:@selector(application:didReceiveRemoteNotification:fetchCompletionHandler:)];
        BOOL noPushPayload = ![launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
            [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
        }
    }
    
    // Register for Push Notitications, if running iOS 8
    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                        UIUserNotificationTypeBadge |
                                                        UIUserNotificationTypeSound);
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                                 categories:nil];
        [application registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    } else {
        // Register for Push Notifications before iOS 8
        [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                         UIRemoteNotificationTypeAlert |
                                                         UIRemoteNotificationTypeSound)];
    }
        
    UIStoryboard *storyboard = [self grabStoryboard];
    
    //show the storyboard
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (UIStoryboard *)grabStoryboard {
    
    UIStoryboard *storyboard;
    
    // detect the height of our screen
    int height = [[UIScreen mainScreen]bounds].size.height;
    
    if (height == 480) {
        storyboard = [UIStoryboard storyboardWithName:@"Main-3.5in" bundle:nil];
        // NSLog(@"Device has a 3.5inch Display.");
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        // NSLog(@"Device has a 4inch Display.");
    }
    
    return storyboard;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler
{
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Opened App from Notification"];
    [mixpanel flush];
    
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0)
    {
        kBadgeNumber = [NSString stringWithFormat:@"%ld", (long)currentInstallation.badge];
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
    
     AppDelegate *tempDelegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
     
     UIViewController *vc = ((UINavigationController *)tempDelegate.window.rootViewController).visibleViewController;
     if ([vc.restorationIdentifier isEqualToString:@"chat"])
     {
         //Notify server that current user is entering chat
         [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"inChatRoom"];
         [[PFUser currentUser] saveInBackground];
     }
    
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    //Notify server that user is exiting live chat
    [[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"inChatRoom"];
    [[PFUser currentUser] saveInBackground];
    
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    if (currentInstallation.badge != 0) {
        currentInstallation.badge = 0;
        [currentInstallation saveEventually];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //[[PFUser currentUser] setObject:[NSNumber numberWithBool:NO] forKey:@"inChatRoom"];
    //[[PFUser currentUser] saveEventually];
}

@end
