//
//  ImageWindow.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 10/1/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "ImageWindow.h"
#import "Constants.h"
#import "HomeTimelineTweet.h"

@interface ImageWindow()

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *overlayLockView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIImageView *overlayImageView;
@property (nonatomic) BOOL imageShow;

@property (strong, nonatomic) HomeTimelineTweet *tweet;
@property (strong, nonatomic) UITableView *superview;

@end

@implementation ImageWindow


-(void)showWindowInFrame:(UITableView *)superview tweet:(HomeTimelineTweet *)tweet{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaLoadnotification:)
                                                 name:MEDIA_LOADED_NOTIFICATION
                                               object:nil];
    
    self.superview = superview;
    self.tweet = tweet;
    [self showImage];
    self.superview.scrollEnabled = NO;
}

-(void)closeWindow{
    [self handleSingleTap:nil];
}

-(BOOL)isActive{
    return self.imageShow;
}
-(void)mediaLoadnotification:(NSNotification *)notification{
    [self closeLockView];
    [self showImage];
}

-(void)configureImageView:(UIImage *)img{
    CGRect frame = self.superview.frame;
    
    float coef = img.size.width / frame.size.width;
    float y = (frame.size.height - (img.size.height/coef))/2;
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, img.size.height/coef)];
    [self.overlayImageView setImage:img];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    [self closeImage];
    [self closeLockView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.superview.scrollEnabled = YES;
}

-(void)showLockView:(bool)closeTap{

    self.imageShow = YES;
    
    self.overlayLockView = [[UIView alloc] init];
    self.overlayLockView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayLockView.frame = self.superview.bounds;
    
    CGRect frame = self.overlayLockView.frame;
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.indicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
    [self.overlayLockView addSubview:self.indicator];
    [self.indicator startAnimating];
    
    if (closeTap){
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self.overlayLockView addGestureRecognizer:singleFingerTap];
    }
    
    if (self.overlayImageView == nil)
        [self.superview addSubview:self.overlayLockView];
    
}

-(void)closeLockView{
    
    [self.indicator stopAnimating];
    [self.overlayLockView removeFromSuperview];
    self.imageShow = NO;
}

-(void)showImage:(UIImage *)img{
    self.imageShow = YES;
    
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayView.frame = self.superview.bounds;
    
    [self configureImageView:img];
    [self.overlayView addSubview:self.overlayImageView];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.overlayView addGestureRecognizer:singleFingerTap];
    
    [self.superview addSubview:self.overlayView];
    
}

-(void)closeImage{
    [self.indicator stopAnimating];
    [self.overlayView removeFromSuperview];
    self.overlayImageView = nil;
    self.imageShow = NO;
}


-(void)showImage{
    
    if (self.tweet.mediaImage){
        [self showImage:self.tweet.mediaImage];
    } else {
        [self showLockView:YES];
    }
}


@end
