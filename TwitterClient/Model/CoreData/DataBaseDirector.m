//
//  DataBaseDirector.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/25/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "DataBaseDirector.h"
#import "Constants.h"
#import <CoreData/CoreData.h>

@interface DataBaseDirector()

@property (strong, nonatomic) NSManagedObjectContext *defaultManagmentObjectContext;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation DataBaseDirector

static DataBaseDirector *instanceDataBaseDirector;

+(DataBaseDirector *)instance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanceDataBaseDirector = [[DataBaseDirector alloc] init];
        
    });
    return instanceDataBaseDirector;
}

//context for background work
- (NSManagedObjectContext *)contextForBGTask {
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:[self mainContext]];
    return context;
}

//context for UI
-(NSManagedObjectContext *)mainContext{
    return [self defaultManagmentObjectContext];
}

-(NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)saveContextForBGTask:(NSManagedObjectContext *)backgroundTaskContext {
    if (backgroundTaskContext.hasChanges) {
        [backgroundTaskContext performBlockAndWait:^{
            NSError *error = nil;
            [backgroundTaskContext save:&error];
        }];
        [self saveDefaultContext:YES];
    }
}

- (void)saveDefaultContext:(BOOL)wait {
    if ([self defaultManagmentObjectContext].hasChanges) {
        [[self defaultManagmentObjectContext] performBlockAndWait:^{
            NSError *error = nil;
            [[self defaultManagmentObjectContext] save:&error];
        }];
    }

    void (^saveDaddyContext) (void) = ^{
        NSError *error = nil;
        [[self managedObjectContext] save:&error];
    };
    if ([[self managedObjectContext] hasChanges]) {
        if (wait)
            [[self managedObjectContext] performBlockAndWait:saveDaddyContext];
        else
            [[self managedObjectContext] performBlock:saveDaddyContext];
    }
}

#pragma mark - Core Data stack

- (NSManagedObjectContext *)defaultManagmentObjectContext{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        dispatch_sync(dispatch_get_main_queue(), ^{
            _defaultManagmentObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
            [_defaultManagmentObjectContext setParentContext:[self managedObjectContext]];
        });
    });
    return _defaultManagmentObjectContext;
}

//main context
- (NSManagedObjectContext *)managedObjectContext
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:self.persistentStoreCoordinator];
    });
   
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:MODEL_NAME withExtension:MODEL_EXTENSION];
        _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    });
    
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:DATA_BASE_NAME];
        
        NSError *error = nil;
        _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
        if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
            NSLog(UNRESOLVED_ERROR, error, [error userInfo]);
            abort();
        }
    });
    
    return _persistentStoreCoordinator;
}



@end
