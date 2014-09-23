//
//  HomeTimelineTweet.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "HomeTimelineTweet.h"
#import "Constants.h"

@interface HomeTimelineTweet()

//@property (atomic) BOOL loadInProcess;

@end

@implementation HomeTimelineTweet

@synthesize profileImage = _profileImage;

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
