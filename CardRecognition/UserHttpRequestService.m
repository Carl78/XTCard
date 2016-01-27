//
//  UserHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/5/30.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "UserHttpRequestService.h"
#import "AppConfig.h"
#import "RMMapper.h"
#import "User.h"

@implementation UserHttpRequestService

- (void)loginWithName:(NSString *)userName password:(NSString *)pwd success:(LoginSuccessBlock)successBlock error:(LoginFailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"userName":userName
                                      ,@"password":pwd,@"deviceType":DeviceType,@"clientIp":LocalIP} mutableCopy];
    [self postRequestToServer:@"Login" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}

-(void)loginWithName:(NSString *)username andPassword:(NSString *)psd success:(SuccessBlock)successBlock error:(LoginFailBlock)errorBlock{
    
    NSMutableDictionary *dicPara = [@{@"userName":username
                                      ,@"password":psd,
                                      @"deviceType":DeviceType,
                                      @"clientIp":LocalIP} mutableCopy];
    
    [self postRequestToServer:@"Login" dicParams:dicPara success:^(NSString *responseString) {
        NSLog(@"%@",responseString);
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        User *user = [RMMapper objectWithClass:[User class] fromDictionary:dataDic];
        
        
        successBlock(user);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
    
}
-(void)updatePwdwithUserId:(NSString*)userId oldPwd:(NSString *)oldPassword newPwd:(NSString *)newPassword success:(SuccessChangeBlock)successBlock error:(LoginFailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"userID":userId
                                      ,@"oldpassword":oldPassword,
                                      @"newpassword":newPassword} mutableCopy];
    
    [self postRequestToServer:@"UpdatePassword" dicParams:dicPara success:^(NSString *responseString) {
        NSLog(@"%@",responseString);
        
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        ExceptionInfo *info = [RMMapper objectWithClass:[ExceptionInfo class] fromDictionary:dataDic];
        
        
        successBlock(info);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
@end
