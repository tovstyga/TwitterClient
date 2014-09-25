//
//  DataBaseDirector.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataBaseDirector : NSObject

+(DataBaseDirector *)instance;

- (NSManagedObjectContext *)contextForBGTask;
- (void)saveContextForBGTask:(NSManagedObjectContext *)backgroundTaskContext;
-(NSManagedObjectContext *)mainContext;
- (void)saveDefaultContext:(BOOL)wait;


@end
