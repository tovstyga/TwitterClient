//
//  Tweet.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * tweetID;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * profileImageURL;
@property (nonatomic, retain) NSString * infoURL;
@property (nonatomic, retain) NSString * mediaURL;
@property (nonatomic, retain) NSData * mediaImage;
@property (nonatomic, retain) NSData * profileImage;

@end
