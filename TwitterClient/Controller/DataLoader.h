//
//  DataLoader.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ObjectsFactory.h"

@interface DataLoader : NSObject

+(void)loadDataFromURL: (NSURL *)url
            parameters: (NSMutableDictionary *)parameters
               creater: (id<ObjectsFactory>) creater;

@end
