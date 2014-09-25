//
//  EntityManager.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "EntityManager.h"
#import "Constants.h"
#import "DataBaseDirector.h"

@implementation EntityManager

-(void)saveHomeTimelineObjects:(NSArray *)objects{
    if (objects.count){
    NSManagedObjectContext *context = [[DataBaseDirector instance] contextForBGTask];
    for (HomeTimelineTweet *tw in objects){
        [Tweet initWithContext:context
                          name:tw.screenName
                          text:tw.text
                     createdAt:tw.createdAt
                       tweetID:tw.tweetID
               profileImageUrl:tw.profileimageURL
                       infoURL:tw.URLinfo
                      mediaURL:tw.mediaURL
                    mediaImage:nil
                  profileImage:nil];
    }
        [[DataBaseDirector instance] saveContextForBGTask:context];
    }
}

-(NSMutableArray *)loadObjects{
    NSMutableArray *objects = [[NSMutableArray alloc] init];
    
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TABLE_NAME];
   
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:PREDICATE_DATE_FIELD ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSManagedObjectContext *context = [[DataBaseDirector instance] contextForBGTask];
    
    __block NSArray *matches;
    
    void (^executeFetch)() = ^{
        NSError *error;
        matches = [context executeFetchRequest:fetchRequest error:&error];
    };
    
    [context performBlockAndWait:executeFetch];

    for (Tweet *t in matches){
        HomeTimelineTweet *newTweet = [[HomeTimelineTweet alloc] initWithTweetOnDataBase:t];
        [objects addObject:newTweet];
    }
    
    return objects;
}

@end
