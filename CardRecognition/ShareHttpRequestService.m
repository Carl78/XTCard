//
//  ShareHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "ShareHttpRequestService.h"
#import "NSArray+ParseArray.h"

@implementation ShareHttpRequestService

-(void)getUserByName:(NSString *)name cardID:(NSString*)cardid
             success:(SuccessBlock)successBlock
               error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"name":name,@"cardId":cardid} mutableCopy];
    [self postRequestToServer:@"GetUser" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)addCardshareByUserIds:(NSArray *)userIds
                     cardIds:(NSArray *)cardIds
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock
{
    NSString *userIdsStr = [NSArray numberArrayToString:userIds];
    NSString *cardIdsStr = [NSArray numberArrayToString:cardIds];
    
    
    NSMutableDictionary *dicPara = [NSMutableDictionary dictionary];
    
    if (userIds && userIds.count>0) {
        [dicPara setObject:userIdsStr forKey:@"userIds"];
    }
    if (cardIds && cardIds.count>0) {
        [dicPara setObject:cardIdsStr forKey:@"cardIds"];
    }
    
    dicPara= [@{@"userIds":userIdsStr,@"cardIds":cardIdsStr} mutableCopy];
    [self postRequestToServer:@"AddCardshare" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)cancelCardShareByCardIds:(NSArray *)cardIds
                        success:(SuccessBlock)successBlock
                          error:(FailBlock)errorBlock
{
    NSString *cardIdsStr = [NSArray numberArrayToString:cardIds];
    NSMutableDictionary *dicPara = [NSMutableDictionary dictionary];
    
    
    dicPara= [@{@"cardIds":cardIdsStr} mutableCopy];
    [self postRequestToServer:@"CancelCardshare" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)getSharedUserByCardId:(NSString *)cardId username:(NSString *) name success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock{
    
    NSMutableDictionary *dicPara = [NSMutableDictionary dictionary];
    
    
    dicPara= [@{@"cardid":cardId,@"name":name} mutableCopy];
    [self postRequestToServer:@"GetSharedUser" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
    
}

-(void)deleteSharedUserByCardId:(NSArray *)cardIds success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock{
    
    NSString *cardIdsStr = [NSArray numberArrayToString:cardIds];
    NSMutableDictionary *dicPara = [NSMutableDictionary dictionary];
    
    
    dicPara= [@{@"shareIds":cardIdsStr} mutableCopy];
    [self postRequestToServer:@"DeleteCardshare" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
    
}
@end
