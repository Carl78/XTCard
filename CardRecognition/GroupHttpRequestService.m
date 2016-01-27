//
//  GroupHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "GroupHttpRequestService.h"
#import "RMMapper.h"

@implementation GroupHttpRequestService
- (void)addGroupWithUserID:(NSString *)uID groupName:(NSString *)name success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"userId":uID
                                      ,@"name":name} mutableCopy];
    [self postRequestToServer:@"AddGroup" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
- (void)modifyGroupByID:(NSString *)gID groupName:(NSString *)name userID:(NSString *)uID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"id":gID
                                      ,@"name":name,@"userId":uID} mutableCopy];
    [self postRequestToServer:@"ModGroupById" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
- (void)deleteGroupByID:(NSString *)gID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"id":gID} mutableCopy];
    [self postRequestToServer:@"DeleteGroupById" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
- (void)getGroupByID:(NSString *)gID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"Id":gID} mutableCopy];
    [self postRequestToServer:@"GetGroupById" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
- (void)getGroupByUserID:(NSString *)uID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"userId":uID} mutableCopy];
    [self postRequestToServer:@"GetGroupByUserId" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}

-(void)getCardTagById:(NSNumber *)Id
              success:(CardByIdBlock)successBlock
                error:(FailBlock)errorBlock
{
    NSMutableDictionary *dicPara = [@{@"id":Id} mutableCopy];
    [self postRequestToServer:@"GetCardTagById" dicParams:dicPara success:^(NSString *responseString) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        CardTag *cardTag = [RMMapper objectWithClass:[CardTag class] fromDictionary:dict];
        
        successBlock(cardTag);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}

-(void)getAllCardTag:(AllCardTagBlock)successBlock error:(FailBlock)errorBlock
{
    [self postRequestToServer:@"GetAllCardTag" dicParams:nil success:^(NSString *responseString) {
        NSData *data = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *dataArr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        
        NSMutableArray *datas = [NSMutableArray array];
        for (NSDictionary *dict in dataArr) {
            CardTag *cardTag = [RMMapper objectWithClass:[CardTag class] fromDictionary:dict];
            [datas addObject:cardTag];
        }
        
        
        successBlock(datas);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
    }];
}
@end
