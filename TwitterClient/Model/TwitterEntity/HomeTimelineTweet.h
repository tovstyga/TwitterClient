//
//  HomeTimelineTweet.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tweet+Methods.h"

@interface HomeTimelineTweet : NSObject

@property (strong, nonatomic) NSDate *createdAt;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) NSString *screenName;
@property (strong, nonatomic) NSURL *profileimageURL;
@property (strong, nonatomic) NSURL *URLinfo;
@property (strong, nonatomic) UIImage *profileImage;
@property (strong, nonatomic) NSString *tweetID;
@property (strong, nonatomic) NSURL *mediaURL;
@property (strong, nonatomic) UIImage *mediaImage;

-(id)initWithTweetOnDataBase:(Tweet *)tweet;

@end
