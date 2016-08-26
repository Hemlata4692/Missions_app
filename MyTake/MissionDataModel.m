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
            for (int i=0; i<[dataArray count]; i++) {
                //insert mission list data in database
                [MissionListDatabase insertDataInMissionTable:[dataArray objectAtIndex:i]];
            }
            [dataArray removeAllObjects];
            //fetch mission list from database
            dataArray = [MissionListDatabase getMisionsList];
            success (dataArray);
        }
    } onFailure:^(NSError *error) {
        failure(error);
         NSLog(@"data model faliure");
    }] ;
}
#pragma mark - end
@end
