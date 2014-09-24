//
//  TweetCustomCell.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/24/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeTimelineTweet.h"

@interface TweetCustomCell : UITableViewCell

- (void)configureCell:(HomeTimelineTweet *)tweet;

@end
