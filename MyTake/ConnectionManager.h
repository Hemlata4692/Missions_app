//
//  ConnectionManager.h
//  MyTake
//
//  Created by Hema on 11/04/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LoginModel;
@class MissionDataModel;
@class MissionDetailModel;

@interface ConnectionManager : NSObject

+ (instancetype)sharedManager;
//Login user
- (void)loginUser:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure;
//Community code
- (void)communityCode:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure;
//Save device token
- (void)sendDevcieToken:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure;
//Get mission list
- (void)getMissionList:(MissionDataModel *)missionData onSuccess:(void (^)(id dataArray))success onFailure:(void (^)(NSError *))failure;
//Get mission detail
- (void)getMissionDetail:(MissionDetailModel *)missionData onSuccess:(void (^)(id dataArray))success onFailure:(void (^)(NSError *))failure;
@end
