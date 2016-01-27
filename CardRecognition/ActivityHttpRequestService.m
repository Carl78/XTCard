//
//  ActivityHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "ActivityHttpRequestService.h"
#import "JSONKit.h"

@implementation ActivityHttpRequestService

-(void)getContactByCard:(NSString *)cardId
             pageNumber:(int)pageNumber
               pageSize:(int)pageSize
                success:(SuccessBlock)successBlock
                  error:(FailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"cardId":cardId,
                                      @"pageNumber":[NSNumber numberWithInt:pageNumber],
                                      @"pageSize":[NSNumber numberWithInt:pageSize]} mutableCopy];
    [self postRequestToServer:@"GetContactByCard" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
-(void)getActivityTypeListWithSuccess:(SuccessBlock)successBlock
                                error:(FailBlock)errorBlock {
    [self postRequestToServer:@"GetActivitytypeList" dicParams:nil success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)addContactByContivity:(Contactactivity *)contivity
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock
{
    NSDictionary *dict = contivity.getDictionaryData;
    
    NSString *JsonString = [dict JSONString];
    
    
    NSMutableDictionary *dicPara = [@{@"contivity":JsonString} mutableCopy];
    [self postRequestToServer:@"AddContact" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)deleteContactByContactId:(NSNumber *)contactId
                        success:(SuccessBlock)successBlock
                          error:(FailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"contactId":contactId} mutableCopy];
    [self postRequestToServer:@"DeleteContact" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
@end
