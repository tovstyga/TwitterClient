//
//  ViewController.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/18/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "ViewController.h"
#import "DataLoader.h"
#import "HomeTimelineTweetFactory.h"
#import "UserTimelineTweetFactory.h"
#import "HomeTimelineTweet.h"
#import "Constants.h"
#import "AppDelegate.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *swapButton;
@property (strong, atomic) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, atomic) NSString *actualURLString;

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIImageView *overlayImageView;

@end

@implementation ViewController

static bool isUserTweetPage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _data = [[NSMutableArray alloc] init];
    
    self.actualURLString = HOME_TIMELINE_URL;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[HomeTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadnotification:)
                                                 name:IMAGE_LOADED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[UserTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaLoadnotification:)
                                                 name:MEDIA_LOADED_NOTIFICATION
                                               object:nil];
    
    self.refresh = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refresh];
    [self.refresh addTarget:self
                     action:@selector(refreshTable)
           forControlEvents:UIControlEventValueChanged];
    
    [self updateData];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    HomeTimelineTweet *tw = nil;
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    tw = self.data[path.row];
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setTweet:tw];
}


-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)dataLoadnotification:(NSNotification *)notification{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMutableArray *newData = (NSMutableArray *)notification.object;
            if (newData.count > 0){
                if (isUserTweetPage){
                    self.data = newData;
                } else {
                    [newData addObjectsFromArray:self.data];
                    self.data = newData;
                }
                
                [self.tableView reloadData];
            }
            [self.refresh endRefreshing];
            self.swapButton.enabled = YES;
        });
    
}

-(void)imageLoadnotification:(NSNotification *)notification{
    if (notification.object == nil)
        return;
    
    HomeTimelineTweet *tw = (HomeTimelineTweet *)notification.object;
    
    __block NSIndexPath *indexPath = nil;
    
    [self.data enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ((HomeTimelineTweet *)obj == tw){
            indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
            *stop = YES;
        }
    }];
    
    if (indexPath != nil){
        dispatch_sync(dispatch_get_main_queue(),^{
            
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                                  withRowAnimation:UITableViewRowAnimationNone];
        });
    }
}

-(void)mediaLoadnotification:(NSNotification *)notification{
    
    HomeTimelineTweet *tweet = (HomeTimelineTweet *)notification.object;
    
    [self configureImageView:tweet];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.indicator stopAnimating];
        [self.overlayView addSubview:self.overlayImageView];
    });
    
}


-(void)updateData{
    NSURL *requestAPI = [NSURL URLWithString:[self actualURLString]];
    
    id <ObjectsFactory> creater = nil;
    
    if (isUserTweetPage) {
        creater = [[UserTimelineTweetFactory alloc] init];
    } else {
        creater = [[HomeTimelineTweetFactory alloc] init];
    }
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:COUNT_VALUE forKey:COUNT];
    
    if ((self.data.count > 0) && !isUserTweetPage) {
        HomeTimelineTweet *tweet = [self.data firstObject];
        [parameters setObject:tweet.tweetID forKey:SINCE_ID];
    }
    
    [DataLoader loadDataFromURL:requestAPI parameters:parameters creater:creater];
}

- (void)refreshTable{
    self.swapButton.enabled = NO;
    [self updateData];
}


- (IBAction)swapBtnClic:(UIBarButtonItem *)sender {
    if (!isUserTweetPage){
        [self setTitle:USER_TWEET];
        self.swapButton.title = HOME_PAGE;
        self.actualURLString = USER_TIMELINE_URL;
        isUserTweetPage = YES;
    } else {
        [self setTitle:HOME_PAGE];
        self.swapButton.title = USER_TWEET;
        self.actualURLString = HOME_TIMELINE_URL;
        isUserTweetPage = NO;
    }
    self.swapButton.enabled = NO;
    [self updateData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    
    return [self.data count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    HomeTimelineTweet *tweet = [self.data objectAtIndex:[indexPath row]];
    
    cell.textLabel.text = tweet.screenName;
    cell.detailTextLabel.text = tweet.text;
    cell.imageView.image = tweet.profileImage;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    HomeTimelineTweet *tw = self.data[indexPath.row];
    
    if (tw.mediaURL){
       
        self.tableView.scrollEnabled = NO;
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        self.overlayView = [[UIView alloc] init];
        self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        self.overlayView.frame = self.tableView.bounds;
        
        
        if (tw.mediaImage){
            [self configureImageView:tw];
            [self.overlayView addSubview:self.overlayImageView];
            
        } else {
            CGRect frame = self.overlayView.frame;
            
            self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            
            self.indicator.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            
            [self.overlayView addSubview:self.indicator];
            
            [self.indicator startAnimating];
        }
        
        UITapGestureRecognizer *singleFingerTap =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleSingleTap:)];
        [self.overlayView addGestureRecognizer:singleFingerTap];
        
        [self.tableView addSubview:self.overlayView];
        
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

-(void)configureImageView:(HomeTimelineTweet *)tweet{
    CGRect frame = self.view.frame;
    
    float coef = tweet.mediaImage.size.width / frame.size.width;
    float y = (frame.size.height - (tweet.mediaImage.size.height/coef))/2;
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, tweet.mediaImage.size.height/coef)];
    self.overlayImageView.image = tweet.mediaImage;
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
    
    self.navigationItem.rightBarButtonItem.enabled = YES;
    self.tableView.scrollEnabled = YES;

    [recognizer.view removeFromSuperview];
    
}
@end
