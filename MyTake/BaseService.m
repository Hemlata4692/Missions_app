//
//  Webservice.m
//  MyTake
//
//  Created by Hema on 11/04/16.
//  Copyright © 2016 Ranosys. All rights reserved.
//

#import "BaseService.h"
#import "NullValueChecker.h"
#import "MainSideBarViewController.h"

@implementation BaseService

@synthesize manager;
@synthesize baseUrl;

#pragma mark - Singleton instance
- (instancetype)init{
    self = [super init];
    if (self) {
        manager = [[AFHTTPRequestOperationManager manager] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    return self;
}

#pragma mark - end

#pragma mark - AFNetworking method
//Get method for community code
- (void)getCommunitycode:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded", nil]];
    //changes for certificate pinning
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"gd_bundle-g2-g1" ofType:@"crt"];
    NSData *certData = [NSData dataWithContentsOfFile:cerPath];
    [securityPolicy setAllowInvalidCertificates:NO];
    [securityPolicy setPinnedCertificates:@[certData]];
    path = [NSString stringWithFormat:@"%@%@",@"http://ccc.my-take.com/api/mobile/",path];
    //end
    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        responseObject=(NSMutableDictionary *)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [myDelegate stopIndicator];
        NSString *messageString;
        if (nil!=[operation.responseObject objectForKey:@"message"]) {
            messageString=[operation.responseObject objectForKey:@"message"];
        }
        else {
            messageString=error.localizedDescription;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
         [alert showWarning:nil title:@"Alert" subTitle:messageString closeButtonTitle:@"Ok" duration:0.0f];
    }];
}

//Get method for other services
- (void)get:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self.manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json",@"application/x-www-form-urlencoded", nil]];
    path = [NSString stringWithFormat:@"%@%@",baseUrl,path];
    [manager GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [myDelegate stopIndicator];
        NSString *messageString;
        if (nil!=[operation.responseObject objectForKey:@"message"]) {
            messageString=[operation.responseObject objectForKey:@"message"];
        }
        else {
            messageString=error.localizedDescription;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        //if application version is lower then 1.2 redirect to mission listing screen
        if ([[messageString lowercaseString] containsString:@"version"] || [[messageString lowercaseString] containsString:@"download"]) {
            [alert addButton:@"Ok" actionBlock:^(void) {
                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                MainSideBarViewController * homeView = [storyboard instantiateViewControllerWithIdentifier:@"MainSideBarViewController"];
                [myDelegate.window setRootViewController:homeView];
                [myDelegate.window makeKeyAndVisible];
            }];
            [alert showWarning:nil title:@"Alert" subTitle:messageString closeButtonTitle:nil duration:0.0f];
        }
        //else 
        else {
         [alert showWarning:nil title:@"Alert" subTitle:messageString closeButtonTitle:@"Ok" duration:0.0f];
        }
    }];
}

//Post method for other services
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters onSuccess:(void (^)(id))success onFailure:(void (^)(NSError *))failure {
    path = [NSString stringWithFormat:@"%@%@",baseUrl,path];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"parse-application-id-removed" forHTTPHeaderField:@"X-Parse-Application-Id"];
    [manager.requestSerializer setValue:@"parse-rest-api-key-removed" forHTTPHeaderField:@"X-Parse-REST-API-Key"];
    [manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [manager POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
         responseObject=(NSMutableDictionary *)[NullValueChecker checkArrayForNullValue:[responseObject mutableCopy]];
        success(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        failure(error);
        [myDelegate stopIndicator];
        NSString *messageString;
        if (nil!=[operation.responseObject objectForKey:@"message"]) {
            messageString=[operation.responseObject objectForKey:@"message"];
        }
        else {
            messageString=error.localizedDescription;
        }
        SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
        [alert showWarning:nil title:@"Alert" subTitle:messageString closeButtonTitle:@"Ok" duration:0.0f];
    }];
}

//Check service response status
- (BOOL)isStatusOK:(id)responseObject {
    NSNumber *number = responseObject[@"isSuccess"];
    NSString *msg;
    switch (number.integerValue)
    {
        case 0:
        {
            msg = responseObject[@"message"];
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:nil title:@"Alert" subTitle:msg closeButtonTitle:@"Ok" duration:0.0f];
            return NO;
        }
        case 1:
            return YES;
            break;
            
        case 2:
        {
            msg = responseObject[@"message"];
        }
            return NO;
            break;
        default: {
            SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
            [alert showWarning:nil title:@"Alert" subTitle:msg closeButtonTitle:@"Ok" duration:0.0f];
        }
            return NO;
            break;
    }
}
//end
#pragma mark - end
@end
