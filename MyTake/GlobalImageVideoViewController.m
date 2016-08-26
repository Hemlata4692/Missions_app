//
//  GlobalImageVideoViewController.m
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "GlobalImageVideoViewController.h"
#import "QuestionModel.h"
#import "MissionDetailDatabase.h"
#import "ImagePreviewViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface GlobalImageVideoViewController () {
    QuestionModel *questionData;
}

@property (strong, nonatomic) NSMutableArray *questionDetailArray;

@end

@implementation GlobalImageVideoViewController
@synthesize attachmentsArray;
@synthesize imageVideoCollectionView;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.questionDetailArray=[[NSMutableArray alloc]init];
    self.attachmentsArray=[[NSMutableArray alloc]init];
    self.questionDetailArray=[MissionDetailDatabase getQuestionDetail];
    questionData=[self.questionDetailArray objectAtIndex:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    //add attachmnets in model
    for (int i =0; i<questionData.answerAttachments.count; i++) {
        NSDictionary * attahmentDict =[questionData.answerAttachments objectAtIndex:i];
        AttachmentsModel * attachments = [[AttachmentsModel alloc]init];
        attachments.attachmentURL = attahmentDict[@"URL"];
        attachments.attachmentType = attahmentDict[@"type"];
        [self.attachmentsArray addObject:attachments];
    }
    //set collection view insets to centre when attachments are less then 3
    if (self.attachmentsArray.count<3 && self.attachmentsArray.count>0 && ([[UIDevice currentDevice] userInterfaceIdiom] !=  UIUserInterfaceIdiomPad)) {
        [imageVideoCollectionView setContentInset:UIEdgeInsetsMake(0, ([[UIScreen mainScreen] bounds].size.width-40)/2-77-(77*(self.attachmentsArray.count-1))+5, 0, 0)];
    }
    else if (self.attachmentsArray.count<4 && self.attachmentsArray.count>0  && ([[UIDevice currentDevice] userInterfaceIdiom] ==  UIUserInterfaceIdiomPad)) {
        [imageVideoCollectionView setContentInset:UIEdgeInsetsMake(0, ([[UIScreen mainScreen] bounds].size.width-40)/2-77-(77*(self.attachmentsArray.count-1))+5, 0, 0)];
    }
    [imageVideoCollectionView reloadData];
    [self.imageVideoCollectionView setCornerRadius:5.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark- Collection view delegate and datasource methods
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return self.attachmentsArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *photoCell = [cv dequeueReusableCellWithReuseIdentifier:@"photoCell" forIndexPath:indexPath];
    AttachmentsModel * attachments=[self.attachmentsArray objectAtIndex:indexPath.row];
    UIImageView *questionImage=(UIImageView *)[photoCell viewWithTag:1];
    UIButton *playButton=(UIButton *)[photoCell viewWithTag:2];
    [questionImage setCornerRadius:5.0f];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        //load image using afnetworking
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:attachments.attachmentURL]
                                                      cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        __weak UIImageView *weakRef = questionImage;
        [questionImage setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        }];
        playButton.hidden=YES;
    }
    else {
        questionImage.image=[UIImage imageNamed:@"video_placeholder.png"];
        playButton.tag=(int)indexPath.row;
        playButton.hidden=NO;
        playButton.userInteractionEnabled=NO;
    }
    return photoCell;
}
#pragma mark - end
@end
