//
//  MissionListDatabase.h
//  MyTake
//
//  Created by Hema on 02/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MissionDataModel.h"
#import "MissionDetailModel.h"

@interface MissionListDatabase : NSObject

+ (void)insertDataInMissionTable:(MissionDataModel *)missionListData;
+ (void)updateDataInMissionTable:(MissionDetailModel *)missionDetail;
+ (void)updateDataInMissionTableAfterMissionStarted:(MissionDataModel *)missionList;
+ (NSMutableArray *)getMisionsList;
+ (NSMutableArray *) getMisionsListFromMisionId;
@end
