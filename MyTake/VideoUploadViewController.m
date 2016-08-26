//
//  VideoUploadViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "VideoUploadViewController.h"

@interface VideoUploadViewController ()

@end

@implementation VideoUploadViewController
@synthesize questionDetailArray;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
     self.navigationItem.title=[UserDefaultManager getValue:@"missionTitle"];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - end

#pragma mark - IBActions
- (IBAction)nextButtonAction:(UIButton *)sender {
        [UserDefaultManager setDictValue:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]+1 totalCount:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:1] intValue]];
        //navigate to screen according to the question
        [self setScreenNavigation:questionDetailArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
}
#pragma mark - end
@end
