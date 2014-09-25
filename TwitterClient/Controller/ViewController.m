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
#import "TweetCustomCell.h"
#import "EntityManager.h"

@interface ViewController ()

@property (strong, atomic) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, atomic) NSString *actualURLString;

@property (strong, nonatomic) UIView *overlayView;
@property (strong, nonatomic) UIView *overlayLockView;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property (strong, nonatomic) UIImageView *overlayImageView;
@property (strong, nonatomic) NSNotification *lastImageShowNotification;


@end

@implementation ViewController

static bool imageShow;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    self.actualURLString = HOME_TIMELINE_URL;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[HomeTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[UserTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaLoadnotification:)
                                                 name:MEDIA_LOADED_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImageNotificationHandler:)
                                                 name:SHOW_IMAGE_NOTIFICATION
                                               object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
    
    self.refresh = [[UIRefreshControl alloc]init];
    [self.tableView addSubview:self.refresh];
    [self.refresh addTarget:self
                     action:@selector(refreshTable)
           forControlEvents:UIControlEventValueChanged];
    
    
    
    [self updateData];
    
    
	// Do any additional setup after loading the view, typically from a nib.
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
   if (self.overlayLockView == nil)
       [self showLockView:NO];
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

- (void) orientationChanged:(NSNotification *)note
{
 
    if ((self.lastImageShowNotification) && (imageShow)){
      
        [self closeImage];
        [self showImageNotificationHandler:self.lastImageShowNotification];
    }
    
}

-(void)dataLoadnotification:(NSNotification *)notification{
        dispatch_sync(dispatch_get_main_queue(), ^{
            NSMutableArray *newData = (NSMutableArray *)notification.object;
            if (newData.count > 0){
              
                [newData addObjectsFromArray:self.data];
                self.data = newData;
               
                [self.tableView reloadData];
            }
            [self.refresh endRefreshing];
            [self closeLockView];
            
            //save database
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EntityManager *manager = [[EntityManager alloc] init];
                if ([self.data count]){
                    
                    [manager saveHomeTimelineObjects:self.data];
                }
            });
            
        });
    
    
}

-(void)updateData{
    
    
    NSURL *requestAPI = [NSURL URLWithString:[self actualURLString]];
    
    id <ObjectsFactory> creater = nil;
    
    creater = [[HomeTimelineTweetFactory alloc] init];
    
    if (self.data == nil){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            EntityManager *manager = [[EntityManager alloc] init];
            
            NSArray *results = [manager loadObjects];
            NSMutableArray *obj = [[NSMutableArray alloc] init];
            for (int i = results.count-1; i >=0; i--){
                [obj addObject:results[i]];

            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:[[creater class] performSelector:@selector(notificationIdentifier)] object:obj];
            
        });
        self.data = [[NSMutableArray alloc] init];
        return;
    }

    
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:COUNT_VALUE forKey:COUNT];
    
    if (self.data.count > 0) {
        HomeTimelineTweet *tweet = [self.data firstObject];
        [parameters setObject:tweet.tweetID forKey:SINCE_ID];
    }
    
    [DataLoader loadDataFromURL:requestAPI parameters:parameters creater:creater];
}

- (void)refreshTable{
    [self updateData];
}


#pragma mark UITableView methods
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
    
    TweetCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    HomeTimelineTweet *tweet = [self.data objectAtIndex:[indexPath row]];
    
    [cell configureCell:tweet];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}


#pragma mark Show Image Methods

-(void)mediaLoadnotification:(NSNotification *)notification{
    
    [self closeLockView];
    [self showImageNotificationHandler:[self lastImageShowNotification]];
    
}

-(void)configureImageView:(UIImage *)img{
    CGRect frame = self.view.frame;
    
    float coef = img.size.width / frame.size.width;
    float y = (frame.size.height - (img.size.height/coef))/2;
    
    self.overlayImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, y, frame.size.width, img.size.height/coef)];
    [self.overlayImageView setImage:img];
    
}

- (void)handleSingleTap:(UITapGestureRecognizer *)recognizer {
 
    [self closeImage];
    [self closeLockView];
}

-(void)showLockView:(bool)closeTap{
    
    imageShow = YES;
    
    self.tableView.scrollEnabled = NO;

    self.overlayLockView = [[UIView alloc] init];
    self.overlayLockView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayLockView.frame = self.tableView.bounds;
    
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
        [self.tableView addSubview:self.overlayLockView];
    
}

-(void)closeLockView{
    self.tableView.scrollEnabled = YES;
    [self.indicator stopAnimating];
    [self.overlayLockView removeFromSuperview];
    imageShow = NO;
}

-(void)showImage:(UIImage *)img{
    imageShow = YES;
    
    self.tableView.scrollEnabled = NO;
    
    self.overlayView = [[UIView alloc] init];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayView.frame = self.tableView.bounds;
    
    [self configureImageView:img];
    [self.overlayView addSubview:self.overlayImageView];
    
    UITapGestureRecognizer *singleFingerTap =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    [self.overlayView addGestureRecognizer:singleFingerTap];
    
    [self.tableView addSubview:self.overlayView];
    
}

-(void)closeImage{
    self.tableView.scrollEnabled = YES;
    [self.indicator stopAnimating];
    [self.overlayView removeFromSuperview];
    self.overlayImageView = nil;
    imageShow = NO;
}

-(void)showImageNotificationHandler:(NSNotification *)notification{
    
        HomeTimelineTweet *tw = notification.object;
        self.lastImageShowNotification = notification;
    
    if (tw.mediaImage){
        [self showImage:tw.mediaImage];
    } else {
        [self showLockView:YES];
    }
}

@end
