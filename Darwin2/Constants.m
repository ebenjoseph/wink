//
//  Constants.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/28/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const kUserKey                = @"user";
NSString *const kUserThumbnailKey       = @"thumbnail";
NSString *const kNumRatingsKey          = @"numRatings";
NSString *const kCurrentRatingKey       = @"currentRating";
NSString *const kWinksKey               = @"winks";
NSString *const kStatusKey              = @"status";
NSString *const kAlertKey               = @"alertShow";
NSString *const kRatingKey              = @"rating";

NSString *kUserSex                       = @"Null";
NSString *kUserSeeking                   = @"Null";
NSString *kUserDistance                  = @"Null";
NSNumber *kUserMinAge                    = 0;
NSNumber *kUserMaxAge                    = 0;
NSString *kUserLatitude                  = @"Null";
NSString *kUserLongitude                  = @"Null";
NSString *kTrial                        = @"trial";
NSString *kAdmitted                     = @"admitted";
NSString *kRejected                     = @"rejected";
PFGeoPoint *kPFGeoPoint                 = nil;
BOOL      kUserFirstTime                 = YES;
NSString *kUserStatus                   = @"Null";
NSString *kBadgeNumber                   = @"0";

NSString *kAgeMinKey                     = @"18";
NSString *kAgeMaxKey                     = @"30";
NSString *kDistanceKey                   = @">5mi";

NSString *kChatKey                      = @"Chat";
NSString *kFromUserKey                  = @"fromUser";
NSString *kToUserKey                    = @"toUser";
NSString *kChatroomKey                  = @"chatroom";
NSString *kTextKey                      = @"text";

NSString *kChannelsKey                  = @"channels";

@end
