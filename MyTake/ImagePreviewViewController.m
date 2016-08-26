//
//  ImagePreviewViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "ImagePreviewViewController.h"
#import "AttachmentsModel.h"
#import "UIViewController+AMSlideMenu.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ImagePreviewViewController ()<UIGestureRecognizerDelegate> {
    AttachmentsModel * attachments;
}
@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *imagePreview;

@end

@implementation ImagePreviewViewController
@synthesize imageURL;
@synthesize attachmentArray;
@synthesize selectedIndex;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    self.previewImageView.userInteractionEnabled=YES;

    if ([imageURL isEqualToString:@""] || nil==imageURL) {
        self.imagePreview.hidden=YES;
        self.previewImageView.hidden=NO;
        self.playButton.hidden=NO;
        //add swipe gesture on iamge view
        UISwipeGestureRecognizer *swipeImageLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesLeft:)];
        swipeImageLeft.delegate=self;
        UISwipeGestureRecognizer *swipeImageRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeImagesRight:)];
        swipeImageRight.delegate=self;
        [swipeImageLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
        [swipeImageRight setDirection:UISwipeGestureRecognizerDirectionRight];
        [self.previewImageView addGestureRecognizer:swipeImageLeft];
        [self.previewImageView addGestureRecognizer:swipeImageRight];
        swipeImageLeft.enabled = YES;
        swipeImageRight.enabled = YES;
        [self swipeImages];
    }
    else {
        self.imagePreview.hidden=NO;
        self.previewImageView.hidden=YES;
        self.playButton.hidden=YES;
        //display image using afnetworking
        __weak UIImageView *weakRef = self.imagePreview;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        [self.imagePreview setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];

    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //if this vc can be poped , then
        if (self.navigationController.viewControllers.count > 1)
        {
            //disabling pan gesture for left menu
            [self disableSlidePanGestureForLeftMenu];
        }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    //if this vc can be poped , then
    if (self.navigationController.viewControllers.count > 1)
    {
        //enable pan gesture for left menu
        [self enableSlidePanGestureForLeftMenu];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)backButtonAction:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)playVideoButtonAction:(id)sender {
    //play video in movie player
    attachments=[attachmentArray objectAtIndex:selectedIndex];
    // NSString* strurl =@"https://s3.amazonaws.com/adplayer/colgate.mp4";
    NSString* strUrl =attachments.attachmentURL;
    NSURL *fileURL = [NSURL URLWithString: strUrl];
    MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [self presentViewController:moviePlayer animated:YES completion:NULL];
}
#pragma mark - end

#pragma mark - Swipe gesture methods
//display current index image on image view
-(void)swipeImages
{
    attachments=[attachmentArray objectAtIndex:selectedIndex];
    if ([attachments.attachmentType isEqualToString:@"image"]) {
        self.playButton.hidden=YES;
        __weak UIImageView *weakRef = self.previewImageView;
        NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:attachments.attachmentURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                  timeoutInterval:60];
        [self.previewImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakRef.contentMode = UIViewContentModeScaleAspectFill;
            weakRef.clipsToBounds = YES;
            weakRef.image = image;
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            
        }];
    }
    else {
        self.playButton.hidden=NO;
        self.previewImageView.image=[UIImage imageNamed:@"video_placeholder.png"];
        self.previewImageView.contentMode=UIViewContentModeScaleAspectFit;
    }
}

//adding left animation to images
- (void)addLeftAnimationPresentToView:(UIView *)viewTobeAnimatedLeft
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.40;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromRight;
    [viewTobeAnimatedLeft.layer addAnimation:transition forKey:nil];
    
}

//adding right animation to images
- (void)addRightAnimationPresentToView:(UIView *)viewTobeAnimatedRight
{
    CATransition *transition = [CATransition animation];
    transition.duration = 0.40;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [transition setValue:@"IntroSwipeIn" forKey:@"IntroAnimation"];
    transition.fillMode=kCAFillModeForwards;
    transition.type = kCATransitionPush;
    transition.subtype =kCATransitionFromLeft;
    [viewTobeAnimatedRight.layer addAnimation:transition forKey:nil];
}

//swipe images in left direction
-(void) swipeImagesLeft:(UISwipeGestureRecognizer *)sender
{
    selectedIndex++;
    if (selectedIndex<attachmentArray.count)
    {
        attachments=[attachmentArray objectAtIndex:selectedIndex];
        if ([attachments.attachmentType isEqualToString:@"image"]) {
            self.playButton.hidden=YES;
            __weak UIImageView *weakRef = self.previewImageView;
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:attachments.attachmentURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            [self.previewImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakRef.contentMode = UIViewContentModeScaleAspectFill;
                weakRef.clipsToBounds = YES;
                weakRef.image = image;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
        }
        else {
            self.playButton.hidden=NO;
            self.previewImageView.image=[UIImage imageNamed:@"video_placeholder.png"];
            self.previewImageView.contentMode=UIViewContentModeScaleAspectFit;
        }

        UIImageView *moveImageView = self.previewImageView;
        [self addLeftAnimationPresentToView:moveImageView];
        }
    else
    {
        selectedIndex--;
    }
}

//swipe images in right direction
-(void) swipeImagesRight:(UISwipeGestureRecognizer *)sender
{
    selectedIndex--;
    if (selectedIndex<attachmentArray.count)
    {
        attachments=[attachmentArray objectAtIndex:selectedIndex];
        if ([attachments.attachmentType isEqualToString:@"image"]) {
            self.playButton.hidden=YES;
            __weak UIImageView *weakRef = self.previewImageView;
            NSURLRequest *imageRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:attachments.attachmentURL] cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                                      timeoutInterval:60];
            [self.previewImageView setImageWithURLRequest:imageRequest placeholderImage:[UIImage imageNamed:@"placeholder.png"] success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                weakRef.contentMode = UIViewContentModeScaleAspectFill;
                weakRef.clipsToBounds = YES;
                weakRef.image = image;
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                
            }];
        }
        else {
            self.playButton.hidden=NO;
            self.previewImageView.image=[UIImage imageNamed:@"video_placeholder.png"];
            self.previewImageView.contentMode=UIViewContentModeScaleAspectFit;
        }

        UIImageView *moveImageView = self.previewImageView;
        [self addRightAnimationPresentToView:moveImageView];
    }
    else
    {
        selectedIndex++;
    }
}
#pragma mark - end

@end
