//
//  InstructionViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "InstructionViewController.h"
#import "UIView+RoundedCorner.h"
#import "MissionDetailModel.h"
#import "DashboardViewController.h"
#import "AMSlideMenuMainViewController.h"
#import "UIViewController+AMSlideMenu.h"
#import "MissionDetailDatabase.h"
#import "MissionDataModel.h"
#import "MissionListDatabase.h"
#import "AnswerModel.h"
#import "AnswerDatabase.h"
#import "GlobalNavigationViewController.h"

@interface InstructionViewController ()
@property (weak, nonatomic) IBOutlet UITextView *instructionDataTextView;
@property (weak, nonatomic) IBOutlet UIButton *discardButton;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UIView *mainContatinerView;
@end

@implementation InstructionViewController
@synthesize missionTimeStamp;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title=@"Instruction";
    //add border and corner radius on view objects
    [self addBorder];
    [myDelegate showIndicator];
    [self performSelector:@selector(getMissionDetails) withObject:nil afterDelay:.1];
    myDelegate.currentNavigationController=self.navigationController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //add menu button
    AMSlideMenuMainViewController *mainVC = [AMSlideMenuMainViewController getInstanceForVC:self];
    if (mainVC.leftMenu)
    {
        // Adding left menu button to navigation bar
        [self addLeftMenuButton];
    }
}

#pragma mark - end

#pragma mark - Custom accessors
//add border and corner radius
- (void)addBorder {
    [self.mainContatinerView setCornerRadius:3.0f];
    [self.discardButton setCornerRadius:20.0f];
    [self.acceptButton setCornerRadius:20.0f];
    [self.discardButton setBorder:self.discardButton color:[UIColor colorWithRed:161.0/255.0 green:161.0/255.0 blue:161.0/255.0 alpha:1.0]];
}
#pragma mark - end

#pragma mark - IBActions
//start mission
- (IBAction)beginExerciseAction:(UIButton *)sender {
    //save answer in database
    AnswerModel *answerData=[AnswerModel sharedUser];
    answerData.stepId=@"-1000";
    [AnswerDatabase insertDataInAnswerTable:answerData];
    [myDelegate showIndicator];
    //change mission status when mission is started
    NSMutableArray *dataArray=[NSMutableArray new];
    dataArray = [MissionListDatabase getMisionsListFromMisionId];
    MissionDataModel*data=[dataArray objectAtIndex:0];
    data.missionStatus=@"In Progress";
    //set updated mission in database
    [MissionListDatabase updateDataInMissionTableAfterMissionStarted:data];
    //fetch questions from database
    NSMutableArray *tempDataArray=[MissionDetailDatabase getQuestionDetail];
    [myDelegate stopIndicator];
    //set question number and total question count in user defaults
    [UserDefaultManager setDictValue:0 totalCount:(int)tempDataArray.count];
    //global navigation to navigate on last answered screen.
    [UserDefaultManager setValue:@"In Progress" key:@"missionStarted"];
    [GlobalNavigationViewController setScreenNavigation:tempDataArray step:0];
}

- (IBAction)declineButtonAction:(UIButton *)sender {
    for (UIViewController *controller in self.navigationController.viewControllers)
    {
        if ([controller isKindOfClass:[DashboardViewController class]])
        {
            [self.navigationController popToViewController:controller animated:YES];
            
            break;
        }
    }
}
#pragma mark - end

#pragma mark - Webservice
//mission details webservice called
- (void)getMissionDetails {
    MissionDetailModel *missionDataModel = [MissionDetailModel new];
    [missionDataModel getMissionDetailOnSuccess:missionTimeStamp success:^(id dataArray) {
        NSLog(@"mission list %@",dataArray);
        MissionDetailModel *missionDetailData = [dataArray objectAtIndex:0];
        self.instructionDataTextView.text=missionDetailData.welcomeMessage;
        [UserDefaultManager setValue:missionDetailData.welcomeMessage key:@"InstructionPopUp"];
        
    } onfailure:^(NSError *error) {
        //in case of faliure fetch data from database
        NSMutableArray *dataArray=[NSMutableArray new];
        dataArray = [MissionDetailDatabase getMissionDetailData];
        MissionDetailModel *missionDetailData = [dataArray objectAtIndex:0];
        self.instructionDataTextView.text=missionDetailData.welcomeMessage;
        [UserDefaultManager setValue:missionDetailData.welcomeMessage key:@"InstructionPopUp"];
    }];
}
#pragma mark - end
@end
