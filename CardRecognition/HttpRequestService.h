//
//  HttpRequestService.h
//  YiHaiShiBei
//
//  Created by mac on 14-10-27.
//  Copyright (c) 2014年 perry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

typedef void (^RequestErrorBlock)(NSInteger errorCode, NSString *errorMessage);
typedef void (^RequestSuccessBlock)(NSString *responseString);

@interface HttpRequestService : NSObject<ASIHTTPRequestDelegate>

- (void)getRequestToServer:(NSString *)actionName requestPara:(NSString *)requestData success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock;

- (void)postFileToServer:(NSString *)actionName Datas:(NSMutableDictionary *)datas dicParams:(NSMutableDictionary *)dicParams success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock;

- (void)postRequestToServer:(NSString *)actionName dicParams:(NSMutableDictionary *)dicParams  success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock;

- (void)httpsRequestToServer:(NSString *)urlStr success:(RequestSuccessBlock)successBlock error:(RequestErrorBlock)errorBlock;

@end
