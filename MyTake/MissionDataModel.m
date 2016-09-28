//
//  MissionDataModel.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionDataModel.h"
#import "ConnectionManager.h"
#import "MissionListDatabase.h"

@implementation MissionDataModel

#pragma mark - Shared instance
+ (instancetype)sharedUser{
    __block MissionDataModel *missionModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        missionModel = [[[self class] alloc] init];
    });
    return missionModel;
}
#pragma mark - end

#pragma mark - Missions list
- (void)getMissionListOnSuccess:(void (^)(id))success onfailure:(void (^)(NSError *))failure{
    [[ConnectionManager sharedManager] getMissionList:self onSuccess:^(id dataArray) {
        if (success) {
            NSMutableArray * alreadyStoredArray;
            @try {
                //fetch already stored data from database
                alreadyStoredArray = [MissionListDatabase getMisionsList];
            } @catch (NSException *exception) {
                NSLog(@"exception is %@",exception);
            }
            if (alreadyStoredArray.count==0) {
                for (int i=0; i<[dataArray count]; i++) {
                    //insert mission list data in database
                    [MissionListDatabase insertDataInMissionTable:[dataArray objectAtIndex:i]];
                }
            }
            else {
                for (int i=0; i<[dataArray count]; i++) {
                    for (int j=0; j<[alreadyStoredArray count]; j++){
                       
                        if (([[[dataArray objectAtIndex:i]missionId] intValue] ==[[[alreadyStoredArray objectAtIndex:j]missionId] intValue]) && (![[[dataArray objectAtIndex:i]missionStatus] isEqualToString:@"none"])) {
                            [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:[[dataArray objectAtIndex:i]missionStatus]];
                        }
                        else if ([[[dataArray objectAtIndex:i]missionId] intValue] ==[[[alreadyStoredArray objectAtIndex:j]missionId] intValue] && ([[[alreadyStoredArray objectAtIndex:j]missionStatus] isEqualToString:@"In Progress"])) {
                             [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:@"In Progress"];
                        }
                        else if([[[dataArray objectAtIndex:i]missionId] intValue]==[[[alreadyStoredArray objectAtIndex:j]missionId]intValue]){
                            [MissionListDatabase updateDataIfStatusChanged:[dataArray objectAtIndex:i] missionStatus:[[dataArray objectAtIndex:i]missionStatus]];
                        }
                    }
                }
            }
           
            [dataArray removeAllObjects];
            //fetch mission list from database
            dataArray = [MissionListDatabase getMisionsList];
            success (dataArray);
        }
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end
@end
