//
//  SearchMetadata.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchMetadata : NSObject

@property (strong, nonatomic) NSString *completedIn;
@property unsigned long long maxID;
@property (strong, nonatomic) NSString *maxIDStr;
@property (strong, nonatomic) NSString *nextResults;
@property (strong, nonatomic) NSString *query;
@property (strong, nonatomic) NSString *refreshURL;
@property int count;
@property unsigned long long sinceID;
@property (strong, nonatomic) NSString *sinceIDStr;

@end
