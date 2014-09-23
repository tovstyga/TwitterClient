//
//  UserTimelineTweetFactory.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/23/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "UserTimelineTweetFactory.h"
#import "HomeTimelineTweet.h"
#import "Constants.h"

@implementation UserTimelineTweetFactory

#define NOTIFICATION_IDENTIFIER @"userTimelineTweetFactory"

-(void)createObjectsWithData: (NSDictionary *)data{
    
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    if (data.count > 0){
        @try {
            
        
        NSArray *array = (NSArray *)data;
        
        for (NSDictionary *dict in array){
            
            HomeTimelineTweet *tweet = [[HomeTimelineTweet alloc] init];
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:DATE_FORMAT_STRING];
            
            tweet.tweetID = [dict objectForKey:ID];
            tweet.createdAt = [formatter dateFromString:[dict objectForKey:CREATED_AT]];
            tweet.text = [dict objectForKey:TEXT];
            
            NSDictionary *user = [dict objectForKey:USER];
            tweet.screenName = [user objectForKey:NAME];
            tweet.profileimageURL = [NSURL URLWithString:[user objectForKey:PROFILE_IMAGE_URL]];
            
            [objects addObject:tweet];
        }
            
        }
        @catch (NSException *exception) {
            NSLog(ERROR_LIMIT_QUERIES);
        }
        @finally {
            
        }

        
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_IDENTIFIER object:objects];
}

+(NSString *)notificationIdentifier{
    return NOTIFICATION_IDENTIFIER;
}

@end
