//
//  OtherHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "OtherHttpRequestService.h"

@implementation OtherHttpRequestService
- (void)getAllIndustry:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
{
    //    [self getRequestToServer:@"GetAllIndustry" requestPara:@"" success:^(NSString *responseString) {
    //        successBlock(responseString);
    //    } error:^(NSInteger errorCode, NSString *errorMessage) {
    //        errorBlock(errorMessage);
    //    }];
    
    [self postRequestToServer:@"GetAllIndustry" dicParams:nil success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
    
}

- (void)getAllCardTag:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    //    [self getRequestToServer:@"GetAllArea" requestPara:@"" success:^(NSString *responseString) {
    //        successBlock(responseString);
    //    } error:^(NSInteger errorCode, NSString *errorMessage) {
    //        errorBlock(errorMessage);
    //    }];
    
    [self postRequestToServer:@"GetAllArea" dicParams:nil success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}

-(void)getGroupByUserId:(NSNumber *)userId
                success:(SuccessBlock)successBlock
                  error:(FailBlock)errorBlock
{
    NSMutableDictionary *dict = [@{@"userId":userId} mutableCopy];
    
    [self postRequestToServer:@"GetGroupByUserId" dicParams:dict success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
-(void)getPlistVersion:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    [self httpsRequestToServer:@"" success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
@end
