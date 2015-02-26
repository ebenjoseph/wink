//
//  Cache.m
//  Darwin2
//
//  Created by Eli Ben-Joseph on 4/1/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import "Cache.h"

@interface Cache()

@property (nonatomic, strong) NSCache *cache;

@end

@implementation Cache


#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forPhoto:(PFObject *)photo {
    NSString *key = [self keyForPhoto:photo];
    [self.cache setObject:attributes forKey:key];
}

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForPhoto:(PFObject *)photo {
    return [NSString stringWithFormat:@"photo_%@", [photo objectId]];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
