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

@interface ViewController ()

@property (strong, atomic) NSMutableArray *data;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UIRefreshControl *refresh;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _data = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataLoadnotification:)
                                                 name:[HomeTimelineTweetFactory notificationIdentifier]
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageLoadnotification:)
                                                 name:IMAGE_LOADED_NOTIFICATION
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
                [newData addObjectsFromArray:self.data];
        
                self.data = newData;
                
                [self.tableView reloadData];
            }
            [self.refresh endRefreshing];
        });
    
}

-(void)updateData{
    NSURL *requestAPI = [NSURL URLWithString:HOME_TIMELINE_URL];
    
    HomeTimelineTweetFactory *factory = [[HomeTimelineTweetFactory alloc] init];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    [parameters setObject:@"100" forKey:COUNT];
    
    if (self.data.count > 0) {
        HomeTimelineTweet *tweet = [self.data firstObject];
        [parameters setObject:tweet.tweetID forKey:SINCE_ID];
    }
    
    [DataLoader loadDataFromURL:requestAPI parameters:parameters creater:factory];
}

- (void)refreshTable{
        [self updateData];
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


@end
