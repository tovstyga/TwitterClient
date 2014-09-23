//
//  Constants.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Constants : NSObject

// JSON keys

#define CREATED_AT @"created_at"

#define TEXT @"text"

#define USER @"user"

#define NAME @"name"

#define PROFILE_IMAGE_URL @"profile_image_url"

#define ENTITIES @"entities"

#define URLS @"urls"

#define kURL @"url"

#define ID @"id_str"

// end JSON keys

#define HOME_TIMELINE_URL @"https://api.twitter.com/1.1/statuses/home_timeline.json"

#define DATE_FORMAT_STRING @"ccc MMM d HH:mm:ss Z yyyy"

#define CELL_IDENTIFIER @"Cell"

#define IMAGE_LOADED_NOTIFICATION @"image loaded"

// param

#define COUNT @"count"

#define SINCE_ID @"since_id"

//end param

// error log message

#define ERROR_ACCOUNT @"Error. Account list is empty"

#define ERROR_ACCESS @"Error. Access denied."

// end error log message
@end
