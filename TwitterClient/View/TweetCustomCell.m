//
//  TweetCustomCell.m
//  TwitterClient
//
//  Created by Alex Tovstyga on 9/24/14.
//  Copyright (c) 2014 Alex Tovstyga. All rights reserved.
//

#import "TweetCustomCell.h"
#import "HomeTimelineTweet.h"
#import "Constants.h"

@interface TweetCustomCell()

@property (strong, atomic) HomeTimelineTweet *tweet;
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *tweetText;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;

@end

@implementation TweetCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

-(id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if(self)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(imageLoadnotification:)
                                                     name:IMAGE_LOADED_NOTIFICATION
                                                   object:nil];
    }
    
    return self;
}

-(void)imageLoadnotification:(NSNotification *)notification{
    if (notification.object == nil)
        return;
    
    if (notification.object != self.tweet)
        return;
    
    dispatch_sync(dispatch_get_main_queue(),^{
        [self.userIcon setImage:self.tweet.profileImage];
    });
    
}

- (void)configureCell:(HomeTimelineTweet *)tweet{
    if (tweet){
        self.tweet = tweet;
        [self.userIcon setImage:self.tweet.profileImage];
        self.titleLabel.text = self.tweet.screenName;
        self.tweetText.text =self.tweet.text;
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:DATE_FORMAT_DISPLAY_STRING];
        
        self.timeLabel.text = [formatter stringFromDate:self.tweet.createdAt];
        
        if (self.tweet.mediaURL) {
            self.imageButton.hidden = NO;
        } else {
            self.imageButton.hidden = YES;
        }
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)imageButtonClick:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:SHOW_IMAGE_NOTIFICATION object:self.tweet];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
