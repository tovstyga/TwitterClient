//
//  SearchBarDelegat.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "SearchBarDelegat.h"
#import "HomeTimelineTweet.h"
#import "Constants.h"


@interface SearchBarDelegat()

@property (strong, atomic) NSMutableArray *data;
@property (strong, atomic) NSMutableArray *dublicateData;

@end

@implementation SearchBarDelegat



-(instancetype)initWithSourceArray:(NSMutableArray*)data{
    self = [super init];
    if (self){
        self.data = [data mutableCopy];
        self.dublicateData = [data mutableCopy];
    }
    return self;
}

-(NSMutableArray *)defaultData{
    return self.dublicateData;
}

-(void)handlesearchForTerm:(NSString *)term{
    self.data = [self.dublicateData mutableCopy];
    
    NSMutableArray *cellsToRemove = [[NSMutableArray alloc] init];
    
    for (HomeTimelineTweet *tweet in self.data){
        if ([tweet.text rangeOfString:term options:NSCaseInsensitiveSearch].location == NSNotFound){
            [cellsToRemove addObject:tweet];
        }
    }
    
    [self.data removeObjectsInArray:cellsToRemove];
    [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGE_NOTIFICATION object:self.data];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    
    
    NSString *searchTerm = searchBar.text;
    [self handlesearchForTerm:searchTerm];
    [searchBar resignFirstResponder];
    
}



-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (searchText.length == 0){
        self.data = [self.dublicateData mutableCopy];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DATA_CHANGE_NOTIFICATION object:self.data];
    } else {
        [self handlesearchForTerm:searchText];
    }
}

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    
 //   [self.imagewindow closeWindow];
    
    return YES;
}


@end
