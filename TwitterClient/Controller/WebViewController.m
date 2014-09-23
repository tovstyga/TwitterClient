//
//  WebViewController.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/22/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "WebViewController.h"
#import "AppDelegate.h"
#import "HomeTimelineTweet.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    HomeTimelineTweet *tweet = [(AppDelegate *)[[UIApplication sharedApplication] delegate] tweet];
    
    self.title = tweet.screenName;
    
    NSURLRequest* request = [NSURLRequest requestWithURL:tweet.URLinfo];
    
    [self.webView setScalesPageToFit:YES];
    [self.webView loadRequest:request];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
