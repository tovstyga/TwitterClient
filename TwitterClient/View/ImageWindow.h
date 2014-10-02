//
//  ImageWindow.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HomeTimelineTweet.h"

@interface ImageWindow : NSObject

-(void)showWindowInFrame:(UIView *)superview tweet:(HomeTimelineTweet *)tweet;
-(void)closeWindow;
-(BOOL)isActive;

@end
