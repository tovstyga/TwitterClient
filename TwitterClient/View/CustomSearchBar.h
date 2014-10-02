//
//  CustomSearchBar.h
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomSearchBar : NSObject

-(void)configSearchViewWithSuperView:(UIView *)superview;
-(void)setDelegate:(id<UISearchBarDelegate>)delegate;
-(void)toggleSearch:(BOOL)shouldOpenSearch;
-(void)resignFirstResponder;

@end
