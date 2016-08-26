//
//  AnswerDatabase.m
//  MyTake
//
//  Created by Hema on 09/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "AnswerDatabase.h"
#import <sqlite3.h>
#import "FMDatabase.h"

@implementation AnswerDatabase
#pragma mark - Insert data in database
+ (void)insertDataInAnswerTable:(AnswerModel *)answerData
{
    FMDatabase *database = [FMDatabase databaseWithPath:[myDelegate getDBPath]];
    [database open];
    NSError *error;
    NSString *multiAnswer;
    //added try catch block to handle null exception
    @try {
        
        NSData *multiAnswerData = [NSJSONSerialization dataWithJSONObject:answerData.multiAnswerDict
                                                                  options:NSJSONWritingPrettyPrinted
                                                                    error:&error];
        multiAnswer = [[NSString alloc] initWithData:multiAnswerData encoding:NSUTF8StringEncoding];
        
    } @catch (NSException *exception) {
        
        NSLog(@"exception is %@",exception);
    }
    
    [database executeUpdate:[NSString stringWithFormat:@"INSERT INTO mission_answer(mission_id,step_id,emoji,longtext_response,rating,rating_why_response,single_answer,multi_answer,place_name,latitude,longitude,text_display,audio_path,video_path,image_folder) values('%@','%@','%@','%@','%@','%@','%@','%@','%@','%f','%f','%@','%@','%@','%@')",[UserDefaultManager getValue:@"missionId"],answerData.stepId,answerData.emojiResponse,answerData.longTextResponse,answerData.ratingResponse,answerData.ratingWhyResponse,answerData.singleAnswer,multiAnswer,answerData.placeName,[answerData.latitude doubleValue],[answerData.longitude doubleValue],answerData.textDisplay,answerData.audioPath,answerData.videoPath,answerData.imageFolder]];
    [database close];
}
#pragma mark - end

@end
