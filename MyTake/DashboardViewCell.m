//
//  DashboardViewCell.m
//  MyTake
//
//  Created by Hema on 29/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "DashboardViewCell.h"

@implementation DashboardViewCell
@synthesize timeContainerView;
@synthesize missionStatusImageView;
@synthesize missionStatusLabel;
@synthesize missionImageView;
@synthesize missionNameLabel;
@synthesize missionTimeLabel;
@synthesize topSeparator;
@synthesize statusView;
@synthesize imageContainerView;

#pragma mark - Load nib
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
#pragma mark - end

#pragma mark - Display data on cells
- (void)displayMissionListData :(MissionDataModel *)missionListData indexPath:(int)indexPath {
    missionStatusLabel.translatesAutoresizingMaskIntoConstraints=YES;
    statusView.translatesAutoresizingMaskIntoConstraints=YES;
    [timeContainerView setCornerRadius:12.0];
    [statusView addShadowWithCornerRadius:statusView color:[UIColor grayColor] borderColor:[UIColor whiteColor] radius:11.0];
    [imageContainerView setCornerRadius:2.0];
    [missionStatusImageView addShadow:missionStatusImageView color:[UIColor grayColor]];
    //set text in labels
    missionNameLabel.text=missionListData.missionTitle;
    [missionNameLabel addShadow:missionNameLabel color:[UIColor grayColor]];
    //set dynamic height of status label
    CGSize size = CGSizeMake(73,50);
    CGRect  textRect=[self setDynamicHeight:size textString:missionListData.missionStatus fontSize:[UIFont fontWithName:@"HelveticaNeueLTCom-Lt" size:13]];
    missionStatusLabel.numberOfLines = 0;
    statusView.frame = CGRectMake(5, 46, 74, textRect.size.height+10);
    missionStatusLabel.frame = CGRectMake(4, 6, 67, textRect.size.height);
   //change status images according to mission status
    if ([missionListData.missionStatus isEqualToString:@"none"]) {
        missionStatusLabel.text=@"Not Started";
        missionStatusImageView.image=[UIImage imageNamed:@"not_started"];
    }
    else if([missionListData.missionStatus isEqualToString:@"In Progress"]){
    missionStatusLabel.text=missionListData.missionStatus;
        missionStatusLabel.textColor=[UIColor colorWithRed:255.0/255.0 green:67.0/255.0 blue:79.0/255.0 alpha:1.0];
        timeContainerView.backgroundColor=[UIColor colorWithRed:255.0/255.0 green:67.0/255.0 blue:79.0/255.0 alpha:0.7];
         missionStatusImageView.image=[UIImage imageNamed:@"in_progress"];
    }
    else if([missionListData.missionStatus isEqualToString:@"Pending Submission"]){
        missionStatusLabel.text=missionListData.missionStatus;
        missionStatusImageView.image=[UIImage imageNamed:@"pending"];
    }
    else if([missionListData.missionStatus isEqualToString:@"Completed"]){
        missionStatusLabel.text=missionListData.missionStatus;
        missionStatusImageView.image=[UIImage imageNamed:@"completed_mission"];
    }
    //set mission image
    NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:missionListData.missionImage]
                                                  cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                              timeoutInterval:60];
    __weak UIImageView *weakRef = missionImageView;
    [missionImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakRef.contentMode = UIViewContentModeScaleAspectFill;
        weakRef.clipsToBounds = YES;
        weakRef.image = image;

    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
    }];
   //set time stamp
    NSTimeInterval timeInterval=[missionListData.timeStamp doubleValue];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeInterval];
   missionTimeLabel.text=[self timeAgoFor:date];
}
//calculate time from time stamp
- (NSString *) timeAgoFor : (NSDate *) date {
    double timeLeft = [date timeIntervalSinceDate:[NSDate date]];
    timeLeft = timeLeft * -1;
    
    if (timeLeft < 86400) {
        int diffInTime = round(timeLeft / 60 / 60);
        if (diffInTime==1) {
            return[NSString stringWithFormat:@"%d hour ago", diffInTime];
        }
        else {
        return[NSString stringWithFormat:@"%d hours ago", diffInTime];
        }
    }
    else if (timeLeft < 86400 * 7) {
        int diffInTime = round(timeLeft / 60 / 60 / 24);
        if (diffInTime==1) {
            return[NSString stringWithFormat:@"%d day ago", diffInTime];
        }
        else {
        return[NSString stringWithFormat:@"%d days ago", diffInTime];
        }
    }
    else {
        int diffInTime = round(timeLeft / (86400 * 7));
        if (diffInTime==1) {
           return[NSString stringWithFormat:@"%d week ago", diffInTime];
        }
        else {
        return[NSString stringWithFormat:@"%d weeks ago", diffInTime];
        }
    }
}
//get dynamic height
-(CGRect)setDynamicHeight:(CGSize)rectSize textString:(NSString *)textString fontSize:(UIFont *)fontSize{
    CGRect textHeight = [textString
                         boundingRectWithSize:rectSize
                         options:NSStringDrawingUsesLineFragmentOrigin
                         attributes:@{NSFontAttributeName:fontSize}
                         context:nil];
    return textHeight;
}
#pragma mark - end
@end
