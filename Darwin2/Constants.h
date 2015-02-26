//
//  Constants.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

@interface Constants : NSObject
{
    
}

#pragma mark - User Profile

extern NSString *const kUserKey;
extern NSString *const kUserThumbnailKey;
extern NSString *const kNumRatingsKey;
extern NSString *const kCurrentRatingKey;
extern NSString *const kWinksKey;
extern NSString *const kStatusKey;
extern NSString *const kAlertKey;
extern NSString *const kRatingKey;

#pragma mark - Variable User Info

extern NSString *kUserSex;
extern NSString *kUserSeeking;
extern NSString *kUserDistance;
extern NSNumber *kUserMinAge;
extern NSNumber *kUserMaxAge;
extern NSString *kUserLatitude;
extern NSString *kUserLongitude;
extern NSString *kTrial;
extern NSString *kAdmitted;
extern NSString *kRejected;
extern PFGeoPoint *kPFGeoPoint;
extern BOOL     kUserFirstTime;
extern NSString *kUserStatus;
extern NSString *kBadgeNumber;

#pragma mark - Preferences

extern NSString *kAgeMinKey;
extern NSString *kAgeMaxKey;
extern NSString *kDistanceKey;

#pragma mark - ChatRoom

extern NSString *kChatKey;
extern NSString *kFromUserKey;
extern NSString *kToUserKey;
extern NSString *kChatroomKey;
extern NSString *kTextKey;

#pragma mark - Notifications

extern NSString *kChannelsKey;

@end
