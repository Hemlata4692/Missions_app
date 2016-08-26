//
//  UserDefaultManager.m
//  Digibi_ecommerce
//
//  Created by Sumit on 08/09/15.
//  Copyright (c) 2015 Ranosys. All rights reserved.
//

#import "UserDefaultManager.h"

@implementation UserDefaultManager

+ (void)setValue:(id)value key:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]setObject:value forKey:key];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

+ (id)getValue:(NSString *)key
{
    return [[NSUserDefaults standardUserDefaults]objectForKey:key];
}

+ (void)removeValue:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:key];
}

+ (void)setDictValue:(int)progressStep totalCount:(int)totalCount {
    NSMutableDictionary * progressDict;
    if (nil==[UserDefaultManager getValue:@"progressDict"])
        {
        progressDict=[[NSMutableDictionary alloc]init];
        }
        else{
        progressDict=[[UserDefaultManager getValue:@"progressDict"] mutableCopy];
        }
    
    [progressDict setObject:[NSString stringWithFormat:@"%d,%d",progressStep,totalCount] forKey:[UserDefaultManager getValue:@"missionId"]];
    [UserDefaultManager setValue:progressDict key:@"progressDict"];

}

+ (void)setInstruction:(id)value key:(NSString *)key {
    NSMutableDictionary * instructionDict;
    if (nil==[UserDefaultManager getValue:@"InstructionPopUp"])
    {
        instructionDict=[[NSMutableDictionary alloc]init];
    }
    else{
        instructionDict=[[UserDefaultManager getValue:@"InstructionPopUp"] mutableCopy];
    }
    
    [instructionDict setObject:value forKey:key];
    [UserDefaultManager setValue:instructionDict key:@"InstructionPopUp"];
}

@end
