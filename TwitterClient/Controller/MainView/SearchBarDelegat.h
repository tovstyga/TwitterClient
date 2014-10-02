//
//  SearchBarDelegat.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchBarDelegat : NSObject<UISearchBarDelegate>

-(instancetype)initWithSourceArray:(NSMutableArray *)data;
-(NSMutableArray *)defaultData;

@end
