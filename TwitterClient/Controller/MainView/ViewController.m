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
#import "HomeTimelineTweet.h"
#import "Constants.h"
#import "AppDelegate.h"
#import "TweetCustomCell.h"
#import "EntityManager.h"
#import "ImageWindow.h"
#import "SearchBarDelegat.h"
#import "CustomSearchBar.h"

@interface ViewController ()

@property (strong, atomic) NSMutableArray *data;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refresh;
@property (strong, atomic) NSString *actualURLString;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *searchButton;
@property (strong, nonatomic) CustomSearchBar *searchBar;
@property (strong, nonatomic) SearchBarDelegat *searchDelegate;

@property (strong, nonatomic) ImageWindow *imagewindow;
@property (strong, nonatomic) NSNotification *lastImageShowNotification;

@end

@implementation ViewController

static bool barShow;

#pragma mark LifeCycle
- (void)viewDidLoad{
    [super viewDidLoad];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    self.actualURLString = HOME_TIMELINE_URL;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[HomeTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showImageNotificationHandler:)
                                                 name:SHOW_IMAGE_NOTIFICATION
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataChangeNotificationHandler:)
                                                 name:DATA_CHANGE_NOTIFICATION
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
}

-(void)viewWillAppear:(BOOL)animated{
    
    self.searchBar = [[CustomSearchBar alloc] init];
    [self.searchBar configSearchViewWithSuperView:self.navigationController.navigationBar];
    self.searchDelegate = [[SearchBarDelegat alloc] initWithSourceArray:_data];
    [self.searchBar setDelegate:self.searchDelegate];
    
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
    [super viewWillAppear:animated];
    
}

- (void)didReceiveMemoryWarning{
   
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
   
    
    HomeTimelineTweet *tw = nil;
    
    UITableViewCell *cell = (UITableViewCell *)sender;
    
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    
    tw = self.data[path.row];
    
    
    if (barShow) {
        [self.searchBar toggleSearch:!barShow];
        barShow = !barShow;
        self.data = [self.searchDelegate defaultData];
        [self.tableView reloadData];
    }
    
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] setTweet:tw];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark Orientation
- (void) orientationChanged:(NSNotification *)note{
  
    if ((self.lastImageShowNotification) && ([self.imagewindow isActive])){
        [self.imagewindow closeWindow];
        [self.imagewindow showWindowInFrame:self.tableView tweet:self.lastImageShowNotification.object];
    }
    
    if (barShow){
        self.data = [self.searchDelegate defaultData];
        [self.tableView reloadData];
        
        [self.searchBar toggleSearch:!barShow];
        barShow = !barShow;
    }
    
    
    
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)){
        [self.navigationItem.rightBarButtonItem setEnabled:NO];
    } else {
        [self.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    
}

#pragma mark Data
-(void)dataChangeNotificationHandler:(NSNotification *)notification{
    self.data = notification.object;
    [self.tableView reloadData];
    [self.imagewindow closeWindow];
}

-(void)dataLoadnotification:(NSNotification *)notification{
        dispatch_sync(dispatch_get_main_queue(), ^{
            
            
            NSMutableArray *newData = (NSMutableArray *)notification.object;
            if (newData.count > 0){
              
                [newData addObjectsFromArray:self.data];
    
                
                
                self.data = newData;
               
                self.searchDelegate = [[SearchBarDelegat alloc] initWithSourceArray:_data];
                [self.searchBar setDelegate:self.searchDelegate];
                
                [self.tableView reloadData];
            }
            [self.refresh endRefreshing];

            
            //save database
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                EntityManager *manager = [[EntityManager alloc] init];
                if ([self.data count]){
                    
                    [manager saveHomeTimelineObjects:self.data];
                }
            });
            self.navigationItem.rightBarButtonItem.enabled = YES;
        });
    
    
}

-(void)updateData{
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
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
    if (barShow){
        [self.refresh endRefreshing];
    } else {
        [self updateData];
    }
}


#pragma mark UITableView methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // Return the number of rows in the section.
    
    return [self.data count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TweetCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    HomeTimelineTweet *tweet = [self.data objectAtIndex:[indexPath row]];
    
    [cell configureCell:tweet];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)showImageNotificationHandler:(NSNotification *)notification{
    [self.searchBar resignFirstResponder];
    self.lastImageShowNotification = notification;
    self.imagewindow = [[ImageWindow alloc] init];
    [self.imagewindow showWindowInFrame:self.tableView tweet:notification.object];
}

- (IBAction)searchButtonClick:(UIBarButtonItem *)sender {
    if (barShow) {
        self.data = [self.searchDelegate defaultData];
        [self.tableView reloadData];
    }
    [self.searchBar toggleSearch:!barShow];
    barShow = !barShow;
    [self.imagewindow closeWindow];
}



@end
