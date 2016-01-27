//
//  StatisticHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "StatisticHttpRequestService.h"

@implementation StatisticHttpRequestService
-(void)getCardGrowthByUserID:(NSNumber *)userID
                   analyType:(NSNumber *)analyType
                   startDate:(NSString *)startDate
                     endDate:(NSString *)endDate
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"userID":userID,
                                      @"analyType":analyType,
                                      @"startDate":startDate,
                                      @"endDate":endDate} mutableCopy];
    [self postRequestToServer:@"GetCardGrowth" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)getCardPieByUserID:(NSNumber *)userID
                  section:(NSNumber *)section
                  success:(SuccessBlock)successBlock
                    error:(FailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"userID":userID,
                                      @"section":section} mutableCopy];
    [self postRequestToServer:@"GetCardPie" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
@end
