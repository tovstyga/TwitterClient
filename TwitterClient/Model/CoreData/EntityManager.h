//
//  EntityManager.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet+Methods.h"
#import "HomeTimelineTweet.h"

@interface EntityManager : NSObject

-(void)saveHomeTimelineObjects:(NSArray *)objects;
-(NSArray *)loadObjects;

@end
