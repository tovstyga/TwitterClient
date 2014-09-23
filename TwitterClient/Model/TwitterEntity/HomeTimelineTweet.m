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

@property (atomic) BOOL loadInProcess;

@end

@implementation HomeTimelineTweet

@synthesize profileImage = _profileImage;

-(UIImage *)profileImage{
    

    if (!(_profileImage) && !(self.loadInProcess)){
        self.loadInProcess = YES;
        [self performSelectorInBackground:@selector(loadImageInBackground) withObject:nil];
    }
    return _profileImage;
}

-(void)loadImageInBackground{
    NSURLRequest *request = [NSURLRequest requestWithURL:self.profileimageURL];
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error == nil){
        _profileImage = [UIImage imageWithData:data];
        [[NSNotificationCenter defaultCenter] postNotificationName:IMAGE_LOADED_NOTIFICATION object:self];
    }
    self.loadInProcess = NO;
}


@end
