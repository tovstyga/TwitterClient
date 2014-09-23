//
//  ObjectsFactory.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ObjectsFactory <NSObject>

-(void)createObjectsWithData: (NSDictionary *)data;
+(NSString *)notificationIdentifier;

@end
