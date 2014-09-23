//
//  AppDelegate.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/18/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTimelineTweet.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) HomeTimelineTweet *tweet;

-(void)setTweet:(HomeTimelineTweet *)tweet;

@end
