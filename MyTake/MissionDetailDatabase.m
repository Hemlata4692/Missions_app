//
//  MissionDetailDatabase.m
//  MyTake
//
//  Created by Hema on 04/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "MissionDetailDatabase.h"
#import <sqlite3.h>
#import "FMDatabase.h"

@implementation MissionDetailDatabase

#pragma mark - Insert data in database
+ (void)insertDataInMissionDetailTable:(MissionDetailModel *)missionDetailData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    NSMutableArray *tempArray=[NSMutableArray new];
    tempArray=[missionDetailData.questionsArray mutableCopy];
    [database open];
    if (0==[self checkRecordExists:missionDetailData.missionId]) {
    for (int i=0; i<tempArray.count; i++) {
        QuestionModel *questionDetail=[tempArray objectAtIndex:i];
        NSError *error;
        NSString *attachments;
        NSString *answerOptions;
        NSString *scaleLabels;
        //added try catch block to handle null exception
        @try {
            NSData *attachmentJsonData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerAttachments
                                                                         options:NSJSONWritingPrettyPrinted
                                                                           error:&error];
            attachments = [[NSString alloc] initWithData:attachmentJsonData encoding:NSUTF8StringEncoding];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        @try {
            NSData *answerOptionsData = [NSJSONSerialization dataWithJSONObject:questionDetail.answerOptions
                                                                        options:NSJSONWritingPrettyPrinted
                                                                          error:&error];
            answerOptions = [[NSString alloc] initWithData:answerOptionsData encoding:NSUTF8StringEncoding];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        @try {
            
            NSData *scaleLabelsData = [NSJSONSerialization dataWithJSONObject:questionDetail.scaleLables
                                                                      options:NSJSONWritingPrettyPrinted
                                                                        error:&error];
            scaleLabels = [[NSString alloc] initWithData:scaleLabelsData encoding:NSUTF8StringEncoding];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO mission_question(mission_id,step_id,type,question,attachments,is_why,scale_min,scale_max,allow_no_rate,max_size,scale_labels,answer_options,timestamp) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",missionDetailData.missionId,questionDetail.questionId,questionDetail.questionType,questionDetail.questionTitle,attachments,questionDetail.isWhy,questionDetail.scaleMinimum,questionDetail.scaleMaximum,questionDetail.allowNoRate,questionDetail.maximumSize,scaleLabels,answerOptions,missionDetailData.missionTimeStamp]];
    }
    
    [database executeUpdate:[NSString stringWithFormat:@"Update mission SET welcome_message = '%@',end_message = '%@' where mission_id = '%@'",missionDetailData.welcomeMessage,missionDetailData.endMessage,missionDetailData.missionId]];
    [database close];
}
}
#pragma mark - end

#pragma mark - Fetch data from database
+ (NSMutableArray *) getMissionDetailData
{
    NSMutableArray *missionMessageDataArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission where mission_id = '%@'",[UserDefaultManager getValue:@"missionId"]]];
    while([results next])
    {
        MissionDetailModel *missionDetail = [[MissionDetailModel alloc] init];
        missionDetail.welcomeMessage = [results stringForColumn:@"welcome_message"];
        missionDetail.endMessage = [results stringForColumn:@"end_message"];
        [missionMessageDataArray addObject:missionDetail];
    }
    [db close];
    return missionMessageDataArray;
}

+ (NSMutableArray *) getQuestionDetail {
    //get question detal data
    NSMutableArray *questionDetailsArray = [[NSMutableArray alloc] init];
    FMDatabase *db = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [db open];
    FMResultSet *results = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM mission_question where mission_id = '%@'",[UserDefaultManager getValue:@"missionId"]]];
    while([results next])
    {
        QuestionModel *questionDetail = [[QuestionModel alloc] init];
        questionDetail.questionId = [results stringForColumn:@"step_id"];
        questionDetail.questionTitle = [results stringForColumn:@"question"];
        questionDetail.questionType = [results stringForColumn:@"type"];
        //[NSNumber numberWithBool:[results stringForColumn:@"is_why"]]
        questionDetail.isWhy = [results stringForColumn:@"is_why"];
        questionDetail.scaleMaximum = [results stringForColumn:@"scale_max"];
        questionDetail.scaleMinimum = [results stringForColumn:@"scale_min"];
        questionDetail.allowNoRate = [results stringForColumn:@"allow_no_rate"];
        questionDetail.maximumSize = [results stringForColumn:@"max_size"];
        NSError *error = nil;
        //added try catch block to handle null exception
        @try {
            NSData * data = [[results stringForColumn:@"attachments"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.answerAttachments = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        @try {
            NSData * data = [[results stringForColumn:@"answer_options"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.answerOptions = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        @try {
            NSData * data = [[results stringForColumn:@"scale_labels"] dataUsingEncoding:NSUTF8StringEncoding];
            questionDetail.scaleLables = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
        } @catch (NSException *exception) {
            
            NSLog(@"exception is %@",exception);
        }
        [questionDetailsArray addObject:questionDetail];
    }
    [db close];
    return questionDetailsArray;
}
#pragma mark - end

#pragma mark - Check record exists in database
+ (int) checkRecordExists:(NSString *)missionId
{
    int count = 0;
    sqlite3 *database = nil;
    if (sqlite3_open([[myDelegate getDBPath] UTF8String], &database) == SQLITE_OK)
    {
        NSString *query=[NSString stringWithFormat:@"SELECT COUNT(*) FROM mission_question where mission_id='%@'",missionId];
        const char* sqlStatement = [query UTF8String];
        sqlite3_stmt *statement;
        if( sqlite3_prepare_v2(database, sqlStatement, -1, &statement, NULL) == SQLITE_OK )
        {
            //Loop through all the returned rows (should be just one)
            while( sqlite3_step(statement) == SQLITE_ROW )
            {
                count = sqlite3_column_int(statement, 0);
            }
        }
        else
        {
            NSLog( @"Failed from sqlite3_prepare_v2. Error is:  %s", sqlite3_errmsg(database) );
        }
        // Finalize and close database.
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return count;
}
#pragma mark - end
@end
