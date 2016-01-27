//
//  UserHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/5/30.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
#import "User.h"
#import "ExceptionInfo.h"

typedef void (^LoginSuccessBlock)(NSString *strToken);
typedef void (^LoginFailBlock)(NSString *strFail);
typedef void (^SuccessBlock)(User *user);
typedef void (^SuccessChangeBlock)(ExceptionInfo *info);

@interface UserHttpRequestService : HttpRequestService

- (void)loginWithName:(NSString *)userName password:(NSString *)pwd success:(LoginSuccessBlock)successBlock error:(LoginFailBlock)errorBlock;

-(void)loginWithName:(NSString *)username andPassword:(NSString *)psd
               success:(SuccessBlock)successBlock
                 error:(LoginFailBlock)errorBlock;

-(void)updatePwdwithUserId:(NSString*)userId oldPwd:(NSString *)oldPassword newPwd:(NSString *)newPassword success:(SuccessChangeBlock)successBlock error:(LoginFailBlock)errorBlock;
@end
