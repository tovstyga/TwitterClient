//
//  Tweet+Methods.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (Methods)

+(Tweet *)initWithContext:(NSManagedObjectContext *)context
                     name:(NSString *)name
                     text:(NSString *)text
                createdAt:(NSDate *)date
                  tweetID:(NSString *)tweetID
          profileImageUrl:(NSURL *)pimage
                  infoURL:(NSURL *)infoURL
                 mediaURL:(NSURL *)mediaURL
               mediaImage:(UIImage *)mediaImage
             profileImage:(UIImage *)profileImage;

@end
