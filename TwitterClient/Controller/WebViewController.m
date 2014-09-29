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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property int requestCount;
@property int counter;
@property (strong, nonatomic) NSTimer *timer;


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

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopSpin) userInfo:nil repeats:YES];
    
     self.requestCount = 0;
    self.counter = 0;
    //[self.webView is]
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    if (self.requestCount == 0){
        [self.indicator startAnimating];
        self.indicator.hidden = NO;
    }
    self.requestCount++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    self.requestCount--;
    self.counter++;
    if (!self.requestCount){
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
       
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"ERROR!" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [self.indicator stopAnimating];
    self.indicator.hidden = YES;
}

-(void)stopSpin{
    if ((self.counter) && ([self.indicator isAnimating])){
        [self.indicator stopAnimating];
        self.indicator.hidden = YES;
        [self.timer invalidate];
        self.timer = nil;
    }
}

@end
