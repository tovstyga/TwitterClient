//
//  CustomSearchBar.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "CustomSearchBar.h"

@interface CustomSearchBar()

@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIView *superView;
@property (strong, nonatomic) UISearchBar *searchBar;

@end

@implementation CustomSearchBar

-(void)configSearchViewWithSuperView:(UIView *)superview{
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:superview];
    CGRect frame = [superview frame];
    self.superView = superview;
    self.searchView = [[UIView alloc] initWithFrame:CGRectMake(-(frame.size.width - frame.size.height),
                                                               0,
                                                               frame.size.width - frame.size.height,
                                                               frame.size.height)];
    
    self.searchView.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
    [superview addSubview:self.searchView];
    
    self.searchBar = [[UISearchBar alloc] initWithFrame:self.searchView.bounds];
    self.searchBar.backgroundColor = [UIColor grayColor];
    
    [self.searchView addSubview:self.searchBar];
  
}

-(void)setDelegate:(id<UISearchBarDelegate>)delegate{
    [self.searchBar setDelegate:delegate];
}

-(void)toggleSearch:(BOOL)shouldOpenSearch{
  
    if (!shouldOpenSearch){
        [self.searchBar resignFirstResponder];
        self.searchBar.text = @"";
    }
    
    [self.animator removeAllBehaviors];
    
   
    CGRect frame = [self.superView frame];
    
    CGFloat gravityDirectionX = (shouldOpenSearch) ? 1.0 : -1.0;
    CGFloat pushMagnitude = (shouldOpenSearch) ? 1.0 : -1.0;
    CGFloat boundaryPointX = (shouldOpenSearch) ? frame.size.width - frame.size.height : -(frame.size.width - frame.size.height);
    
    UIGravityBehavior *gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.searchView]];
    gravityBehavior.gravityDirection = CGVectorMake(gravityDirectionX, 0.0);
    [self.animator addBehavior:gravityBehavior];
    
    
    UICollisionBehavior *collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.searchView]];
    [collisionBehavior addBoundaryWithIdentifier:@"searchBoundary"
                                       fromPoint:CGPointMake(boundaryPointX, 20.0)
                                         toPoint:CGPointMake(boundaryPointX, frame.size.height)];
    [self.animator addBehavior:collisionBehavior];
    
    
    UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.searchView]
                                                                    mode:UIPushBehaviorModeInstantaneous];
    pushBehavior.magnitude = pushMagnitude;
    [self.animator addBehavior:pushBehavior];
    
    
    UIDynamicItemBehavior *searchViewBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.searchView]];
    searchViewBehavior.elasticity = 0.4;
    [self.animator addBehavior:searchViewBehavior];
    
}

-(void)resignFirstResponder{
    [self.searchBar resignFirstResponder];
}

@end
