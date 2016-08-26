//
//  MissionDetailDatabase.h
//  MyTake
//
//  Created by Hema on 04/08/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MissionDetailModel.h"
#import "QuestionModel.h"
#import "AnswerOptionsModel.h"
#import "AttachmentsModel.h"

@interface MissionDetailDatabase : NSObject

+ (void)insertDataInMissionDetailTable:(MissionDetailModel *)missionListData;
+ (NSMutableArray *) getMissionDetailData;
+ (NSMutableArray *) getQuestionDetail;
@end
