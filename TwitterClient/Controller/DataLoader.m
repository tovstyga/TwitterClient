//
//  DataLoader.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "DataLoader.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "ObjectsFactory.h"
#import "Constants.h"



@implementation DataLoader

+(void)loadDataFromURL:(NSURL *)url
            parameters:(NSMutableDictionary *)parameters
               creater:(id<ObjectsFactory>)creater{
    
    ACAccountStore *account = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [account accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [account requestAccessToAccountsWithType:accountType
                                     options:nil
                                  completion:^(BOOL granted, NSError *error)
     {
         
         if (granted == YES){
             NSArray *arrayOfAccounts = [account accountsWithAccountType:accountType];
             if ([arrayOfAccounts count] > 0)
             {
                 ACAccount *activeTwitterAccount = [arrayOfAccounts lastObject];
                 
                 SLRequest *posts = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:parameters];
                 
                 posts.account = activeTwitterAccount;
                 
                 [posts performRequestWithHandler:^(NSData *response, NSHTTPURLResponse *urlResponse, NSError *error){
                     
                     NSDictionary *templateDict = [NSJSONSerialization JSONObjectWithData:response
                                                                                  options:NSJSONReadingMutableLeaves
                                                                                    error:&error];
                   
                     if (error) {
                        NSLog(@"%@", error.debugDescription);
                         [DataLoader pushNotification:creater];
                         
                     } else {
                         [creater createObjectsWithData:templateDict];
                     }
                 }];
                 
             } else {
                 NSLog(ERROR_ACCOUNT);
                 [DataLoader pushNotification:creater];
             }
             
         } else {
             NSLog(ERROR_ACCESS);
             [DataLoader pushNotification:creater];
         }
     }];
    
    
}

+(void)pushNotification:(id<ObjectsFactory>)creater{
        [[NSNotificationCenter defaultCenter] postNotificationName:[[creater class] performSelector:@selector(notificationIdentifier)] object:nil];
}
@end
