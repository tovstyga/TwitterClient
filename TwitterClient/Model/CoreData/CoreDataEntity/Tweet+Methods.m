//
//  Tweet+Methods.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "Tweet+Methods.h"
#import "Constants.h"
#import "DataBaseDirector.h"

@implementation Tweet (Methods)

+(Tweet *)initWithContext:(NSManagedObjectContext *)context
                     name:(NSString *)name
                     text:(NSString *)text
                createdAt:(NSDate *)date
                  tweetID:(NSString *)tweetID
          profileImageUrl:(NSURL *)pimage
                  infoURL:(NSURL *)infoURL
                 mediaURL:(NSURL *)mediaURL
               mediaImage:(UIImage *)mediaImage
             profileImage:(UIImage *)profileImage{
    
    __block Tweet *tweet = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:TABLE_NAME];
    request.predicate = [NSPredicate predicateWithFormat:PREDICATE_FIELD_NAME, tweetID];
    
    __block NSError *error;
    
    __block NSArray *matches;
    
    
    void (^executeFetch)() = ^{
        //NSError *error;
        matches = [context executeFetchRequest:request error:&error];
    };
    
    [context performBlockAndWait:executeFetch];
    
    if (!matches || error || ([matches count] > 1)){
        //NSLog(@"error news");
    } else if ([matches count]){
        tweet = [matches firstObject];
    } else {
        void(^insert)() = ^{
            tweet = [NSEntityDescription insertNewObjectForEntityForName:TABLE_NAME inManagedObjectContext:context];
        };
        
        [context performBlockAndWait:insert];

        tweet.name = name;
        tweet.text = text;
        tweet.createdAt = date;
        tweet.tweetID = tweetID;
        tweet.profileImageURL = [pimage absoluteString];
        tweet.infoURL = [infoURL absoluteString];
        tweet.mediaURL = [mediaURL absoluteString];
        
        
        if (mediaImage){
            CGDataProviderRef provider = CGImageGetDataProvider(mediaImage.CGImage);
            tweet.mediaImage = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
        }
        if (profileImage){
            CGDataProviderRef provider = CGImageGetDataProvider(profileImage.CGImage);
            tweet.profileImage = (id)CFBridgingRelease(CGDataProviderCopyData(provider));
        }
        
    }
    
    return tweet;
}



@end
