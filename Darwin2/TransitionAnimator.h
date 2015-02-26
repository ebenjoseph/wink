//
//  TransitionAnimator.h
//  Darwin2
//
//  Created by Eli Ben-Joseph on 7/6/14.
//  Copyright (c) 2014 Eli Ben-Joseph. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
