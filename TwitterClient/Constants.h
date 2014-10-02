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

#define MEDIA @"media"

#define MEDIA_URL @"media_url"

#define URLS @"urls"

#define kURL @"url"

#define ID @"id_str"


// end JSON keys

#define HOME_TIMELINE_URL @"https://api.twitter.com/1.1/statuses/home_timeline.json"

#define USER_TIMELINE_URL @"https://api.twitter.com/1.1/statuses/user_timeline.json"

#define DATE_FORMAT_STRING @"ccc MMM d HH:mm:ss Z yyyy"

#define DATE_FORMAT_DISPLAY_STRING @"HH:mm:ss d MMM yyyy"

#define CELL_IDENTIFIER @"Cell"

#define IMAGE_LOADED_NOTIFICATION @"image loaded"

#define MEDIA_LOADED_NOTIFICATION @"media loaded"

#define DATA_CHANGE_NOTIFICATION @"data change"

// param

#define COUNT @"count"

#define COUNT_VALUE @"200"

#define SINCE_ID @"since_id"

//end param

// error log message

#define ERROR_ACCOUNT @"Error. Account list is empty"

#define ERROR_ACCESS @"Error. Access denied."

#define ERROR_LIMIT_QUERIES @"exceeding the limit of queries"

// end error log message

#define HOME_PAGE @"Home page"

#define USER_TWEET @"User tweet"

#define SHOW_IMAGE_NOTIFICATION @"how image"

//core data

#define MODEL_EXTENSION @"momd"

#define MODEL_NAME @"Model"

#define DATA_BASE_NAME @"CoreData.sqlite"

#define UNRESOLVED_ERROR @"Unresolved error %@, %@"

#define TABLE_NAME @"Tweet"

#define PREDICATE_FIELD_NAME @"tweetID = %@"

#define PREDICATE_DATE_FIELD @"createdAt"

//end core data

@end
