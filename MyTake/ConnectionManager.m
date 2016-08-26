//
//  ConnectionManager.m
//  Demo
//
//  Created by shiv vaishnav on 22/06/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//



#import "ConnectionManager.h"
#import "LoginModel.h"
#import "LoginService.h"
#import "MissionDataModel.h"
#import "MissionService.h"
#import "MissionDetailModel.h"
#import "NullValueChecker.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AttachmentsModel.h"
#import "MissionListDatabase.h"

@implementation ConnectionManager

#pragma mark - Shared instance
+ (instancetype)sharedManager{
    static ConnectionManager *connectionManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        connectionManager = [[[self class] alloc] init];
    });
    return connectionManager;
}
#pragma mark - end

#pragma mark - Community code
- (void)communityCode:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure{
    LoginService *communityCode = [[LoginService alloc] init];
    //parse data from server response and store in datamodel
    [communityCode communityCode:userData onSuccess:^(id response) {
        response=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[response mutableCopy]];
        NSLog(@"comunity code response %@",response);
        userData.code = response[@"code"];
        userData.baseUrl = response[@"url"];
        [UserDefaultManager setValue:userData.baseUrl key:@"baseUrl"];
        success(userData);
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Login user
- (void)loginUser:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure{
    LoginService *loginService = [[LoginService alloc] init];
    [loginService loginUser:userData onSuccess:^(id response) {
        //parse data from server response and store in datamodel
        response=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[response mutableCopy]];
        NSLog(@"UserLogin response %@",response);
        userData.apiKey=response[@"ApiKey"];
        userData.userId=response[@"UserID"];
        userData.userName=response[@"Username"];
        userData.userImage=response[@"UserAvatar"];
        userData.userThumbnailImage=response[@"UserAvatarThumb"];
        success(userData);
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Send device token
- (void)sendDevcieToken:(LoginModel *)userData onSuccess:(void (^)(LoginModel *userData))success onFailure:(void (^)(NSError *))failure{
    LoginService *deviceToken = [[LoginService alloc] init];
    [deviceToken saveDeviceToken:userData onSuccess:^(id response) {
        //send device token to server for push notification
        response=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[response mutableCopy]]; 
        NSLog(@"device token  response %@",response);
        success(userData);
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Mission list
- (void)getMissionList:(MissionDataModel *)missionData onSuccess:(void (^)(id dataArray))success onFailure:(void (^)(NSError *))failure {
    MissionService *missionService = [[MissionService alloc] init];
    [missionService getMissionList:missionData onSuccess:^(id response) {
        response=(NSMutableArray *)[NullValueChecker checkArrayForNullValue:[response mutableCopy]];
        //parse data from server response and store in datamodel
        NSLog(@"mission response response %@",response);
        NSMutableArray *dataArray = [NSMutableArray new];
        MissionDataModel*dataStored;
        //added try catch block to handle null exception
        @try {
            //fetch already stored data from database
            NSMutableArray * alreadyStoredArray = [MissionListDatabase getMisionsListFromMisionId];
             dataStored=[alreadyStoredArray objectAtIndex:0];
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        for (int i =0; i<[response count]; i++)
        {
            __block MissionDataModel *tempModel=missionData;
            tempModel=[MissionDataModel new];
            tempModel.missionId=[response objectAtIndex:i][@"MissionID"];
            tempModel.missionImage=[response objectAtIndex:i][@"Image"];
            tempModel.missionTitle=[response objectAtIndex:i][@"Title"];
            //compare mission status from server and database and amintain its status locally.
            if (![dataStored.missionStatus isEqualToString:@"none"] && nil!=dataStored.missionStatus) {
                tempModel.missionStatus=@"In Progress";
            }
            else {
            tempModel.missionStatus=[response objectAtIndex:i][@"MissionStatus "];
            }
            tempModel.missionStartDate=[response objectAtIndex:i][@"StartDate"];
            tempModel.missionEndDate=[response objectAtIndex:i][@"EndDate"];
            tempModel.timeStamp=[response objectAtIndex:i][@"TimeStamp"];
            [dataArray addObject:tempModel];
        }
        success(dataArray);
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end

#pragma mark - Mission detail
- (void)getMissionDetail:(MissionDetailModel *)missionData onSuccess:(void (^)(id dataArray))success onFailure:(void (^)(NSError *))failure {
    MissionService *missionService = [[MissionService alloc] init];
    [missionService getMissionDetail:missionData onSuccess:^(id response) {
        response=(NSMutableDictionary *)[NullValueChecker checkDictionaryForNullValue:[response mutableCopy]];
        [myDelegate stopIndicator];
        //parse data from server response and store in datamodel
        NSLog(@"mission response response %@",response);
        missionData.welcomeMessage=response[@"WelcomeMessage"];
        missionData.endMessage=response[@"EndMessage"];
        missionData.missionId=response[@"MissionID"];
        missionData.questionsArray=[[NSMutableArray alloc]init];
        NSArray *questionArray=response[@"Steps"];
        for (int i =0; i<questionArray.count; i++)
        {
            NSDictionary * questionDict =[questionArray objectAtIndex:i];
            QuestionModel * questionList = [[QuestionModel alloc]init];
            questionList.questionId = questionDict[@"StepID"];
            questionList.questionType = questionDict[@"Type"];
            questionList.questionTitle = questionDict[@"Question"];
            questionList.allowNoRate = questionDict[@"AllowNoRate"];
            questionList.isWhy = questionDict[@"IsWhy"];
            questionList.scaleMaximum = questionDict[@"ScaleMax"];
            questionList.scaleMinimum = questionDict[@"ScaleMin"];
            questionList.maximumSize = questionDict[@"MaxSize"];
            questionList.answerOptions=[[NSMutableArray alloc]init];
            questionList.answerAttachments=[[NSMutableArray alloc]init];
            questionList.scaleLables=[[NSDictionary alloc]init];
            //added try catch block to handle null exception
            @try {
                questionList.scaleLables = [questionDict[@"ScaleLabels"] copy];
                questionList.answerOptions =[questionDict[@"AnswerOptions"] mutableCopy];
                questionList.answerAttachments =[questionDict[@"Attachments "] mutableCopy];
            } @catch (NSException *exception) {
                
                NSLog(@"exception is %@",exception);
            }
            [missionData.questionsArray addObject:questionList];
        }
        success(missionData);
    } onFailure:^(NSError *error) {
        failure(error);
    }] ;
}
#pragma mark - end


@end
