//
//  DashboardViewController.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "DashboardViewController.h"
#import "DashboardViewCell.h"
#import "MissionDataModel.h"
#import "InstructionViewController.h"
#import "MissionListDatabase.h"
#import "TextDisplayViewController.h"
#import "MissionDetailDatabase.h"
#import "GlobalNavigationViewController.h"

@interface DashboardViewController () {
    UIRefreshControl *refreshControl;
}

@property (weak, nonatomic) IBOutlet UITableView *missionTableView;
@property (weak, nonatomic) IBOutlet UILabel *noResultFoundLabel;
@property (strong,nonatomic) NSMutableArray *missionListDataArray;
@end

@implementation DashboardViewController
@synthesize missionTableView;

#pragma mark - Life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=@"Missions";
    self.missionListDataArray=[[NSMutableArray alloc]init];
    // Pull To Refresh
    refreshControl = [[UIRefreshControl alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2, 0, 10, 10)];
    [self.missionTableView addSubview:refreshControl];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    self.missionTableView.alwaysBounceVertical = YES;
    [UserDefaultManager setValue:nil key:@"missionStarted"];
    [myDelegate showIndicator];
    [self performSelector:@selector(getAllMissions) withObject:nil afterDelay:.1];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    //set current navigation
    myDelegate.currentNavigationController=self.navigationController;
}
#pragma mark - end

#pragma mark - Refresh table
//Pull to refresh implementation on my submission data
- (void)refreshTable
{
    [self performSelector:@selector(getAllMissions) withObject:nil afterDelay:.1];
    [refreshControl endRefreshing];
}
#pragma mark - end

#pragma mark - Webservice
//Get mission liost data from webservice
- (void)getAllMissions {
    MissionDataModel *missionModel = [MissionDataModel new];
    [missionModel getMissionListOnSuccess:^(id dataArray) {
        NSLog(@"mission list %@",dataArray);
        self.missionListDataArray=[dataArray mutableCopy];
        //if no result found
        if (0==self.missionListDataArray.count || nil==self.missionListDataArray) {
            self.noResultFoundLabel.hidden=NO;
            self.missionTableView.hidden=YES;
            self.noResultFoundLabel.text=@"No mission assign to you yet.";
        }
        [missionTableView reloadData];
        
    } onfailure:^(NSError *error) {
        //webservice faliure fetch data from database
        NSMutableArray *dataArray=[NSMutableArray new];
        dataArray = [MissionListDatabase getMisionsList];
        self.missionListDataArray=[dataArray mutableCopy];
        //if no result found
        if (0==self.missionListDataArray.count || nil==self.missionListDataArray) {
            self.noResultFoundLabel.hidden=NO;
            self.missionTableView.hidden=YES;
            self.noResultFoundLabel.text=@"No mission assign to you yet.";
        }
        [missionTableView reloadData];
    }];
    
}
#pragma mark - end

#pragma mark - Table view delegate and datasource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.missionListDataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *simpleTableIdentifier = @"missionCell";
    DashboardViewCell *missionCell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (missionCell == nil)
    {
        missionCell = [[DashboardViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }
    //hide separator if result is only 1 mission
    if (self.missionListDataArray.count==1) {
        missionCell.topSeparator.hidden=YES;
        missionCell.bottomSeparator.hidden=YES;
    }
    if (indexPath.row==0) {
        missionCell.topSeparator.hidden=YES;
    }
    //display data on cells
    MissionDataModel *data=[self.missionListDataArray objectAtIndex:indexPath.row];
    [missionCell displayMissionListData:data indexPath:(int)indexPath.row];
    [myDelegate stopIndicator];
    return missionCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [myDelegate showIndicator];
    MissionDataModel *data=[self.missionListDataArray objectAtIndex:indexPath.row];
    [UserDefaultManager setValue:data.missionId key:@"missionId"];
    [UserDefaultManager setValue:data.missionTitle key:@"missionTitle"];
    NSMutableArray *tempDataArray=[MissionDetailDatabase getQuestionDetail];
    NSMutableArray *dataArray=[MissionDetailDatabase getMissionDetailData];
    MissionDetailModel *missionDetailData = [dataArray objectAtIndex:0];
    [myDelegate stopIndicator];
    //move to last answered question
    if (nil!=[UserDefaultManager getValue:@"progressDict"] && [[[UserDefaultManager getValue:@"progressDict"] allKeys] containsObject:[UserDefaultManager getValue:@"missionId"]]) {
        [UserDefaultManager setValue:missionDetailData.welcomeMessage key:@"InstructionPopUp"];
        [UserDefaultManager setValue:@"In Progress" key:@"missionStarted"];
        [GlobalNavigationViewController setScreenNavigation:tempDataArray step:[[[[[UserDefaultManager getValue:@"progressDict"] objectForKey:[UserDefaultManager getValue:@"missionId"]] componentsSeparatedByString:@","] objectAtIndex:0] intValue]];
    }
    // move to instruction screen
    else {
        UIStoryboard * storyboard=storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        InstructionViewController *instructionView =[storyboard instantiateViewControllerWithIdentifier:@"InstructionViewController"];
        instructionView.missionTimeStamp=data.timeStamp;
        [self.navigationController pushViewController:instructionView animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    //set dynamic height according to screen size
    CGSize dynamicHeight;
    dynamicHeight =  CGSizeMake(self.view.frame.size.width, (((float)155/(float)320)*self.view.frame.size.width));
    return dynamicHeight.height;
}

#pragma mark - end

@end
