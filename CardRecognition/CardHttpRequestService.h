//
//  CardHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
#import "CardModel.h"

typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);
@interface CardHttpRequestService : HttpRequestService
//- (void)addCardWithUserID:(NSString *)uID groupName:(NSString *)name success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)deleteCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getCardWithCompangOrName:(NSString *)companyOrName pageNumber:(int)page pageSize:(int)size sortField:(int)sort userId:(int)ID hasShare:(BOOL)hasShare success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;

-(void)addBusinessCardByItem:(CardModel *)item
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock;

-(void)getBusinessCardById:(NSNumber *)cardID
                   success:(SuccessBlock)successBlock
                     error:(FailBlock)errorBlock;
@end
