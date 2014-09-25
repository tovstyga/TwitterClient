//
//  HomeTimelineTweet.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "HomeTimelineTweet.h"
#import "Constants.h"
#import "Tweet.h"

@interface HomeTimelineTweet()

//@property (atomic) BOOL loadInProcess;

@end

@implementation HomeTimelineTweet

@synthesize profileImage = _profileImage;

-(id)initWithTweetOnDataBase:(Tweet *)tweet{
    self = [super init];
    if (self){
        _tweetID = tweet.tweetID;
        _createdAt = tweet.createdAt;
        _text = tweet.text;
        _screenName = tweet.name;
        _profileimageURL = [NSURL URLWithString:tweet.profileImageURL];
        _mediaURL = [NSURL URLWithString:tweet.mediaURL];
        _URLinfo = [NSURL URLWithString:tweet.infoURL];
        _mediaImage = [UIImage imageWithData:tweet.mediaImage];
        _profileImage = [UIImage imageWithData:tweet.profileImage];
    }
    return self;
}

-(UIImage *)profileImage{
    

    if (!(_profileImage)/* && !(self.loadInProcess)*/){
        //self.loadInProcess = YES;
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:IMAGE_LOADED_NOTIFICATION];
    }
    return _profileImage;
}

-(UIImage *)mediaImage{
    if (!(_mediaImage)/* && !(self.loadInProcess)*/){
     //   self.loadInProcess = YES;
        [self performSelectorInBackground:@selector(loadImageInBackground:) withObject:MEDIA_LOADED_NOTIFICATION];
    }
    
    return _mediaImage;
}

-(void)loadImageInBackground:(NSString *)notificationName{
    NSURLRequest *request = nil;
    
    if ([notificationName isEqualToString:IMAGE_LOADED_NOTIFICATION]){
        request = [NSURLRequest requestWithURL:self.profileimageURL];
    } else {
        request = [NSURLRequest requestWithURL:self.mediaURL];
    }
   
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error == nil){
        if ([notificationName isEqualToString:IMAGE_LOADED_NOTIFICATION]){
            _profileImage = [UIImage imageWithData:data];
        } else {
            _mediaImage = [UIImage imageWithData:data];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName object:self];
    }
 //   self.loadInProcess = NO;
}




@end
