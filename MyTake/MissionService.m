//
//  MissionService.m
//  MyTake
//
//  Created by Hema on 12/07/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionService.h"
#import "MissionDataModel.h"
#import "MissionDetailModel.h"

static NSString *kMissionList=@"/api/missions/getAllMissions";
static NSString *kMissionDetail=@"/api/missions/getMissionDetails";

@implementation MissionService


#pragma mark- Missons list
- (void)getMissionList:(MissionDataModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"]};
    NSLog(@"request mission dict %@",parameters);
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super get:kMissionList parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Misson details
- (void)getMissionDetail:(MissionDetailModel *)missionData onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure
{
    NSDictionary *parameters = @{@"api_token" :[UserDefaultManager getValue:@"apiKey"],@"MissionID":[UserDefaultManager getValue:@"missionId"]};
    NSLog(@"request mission detail dict %@",parameters);
    super.baseUrl=[UserDefaultManager getValue:@"baseUrl"];
    [super get:kMissionDetail parameters:parameters onSuccess:success onFailure:failure];
}
#pragma mark- end

#pragma mark- Upload mission
//upload mission to server
#pragma mark- end
@end
