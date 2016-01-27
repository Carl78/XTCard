//
//  GroupHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
#import "CardTag.h"

typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^AllCardTagBlock)(NSArray *allCardTag);
typedef void (^CardByIdBlock) (CardTag *cardTag);
typedef void (^FailBlock)(NSString *strFail);

@interface GroupHttpRequestService : HttpRequestService
- (void)addGroupWithUserID:(NSString *)uID groupName:(NSString *)name success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)modifyGroupByID:(NSString *)gID groupName:(NSString *)name userID:(NSString *)uID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)deleteGroupByID:(NSString *)gID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getGroupByID:(NSString *)gID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getGroupByUserID:(NSString *)gID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;

-(void)getCardTagById:(NSNumber *)Id
              success:(CardByIdBlock)successBlock
                error:(FailBlock)errorBlock;

-(void)getAllCardTag:(AllCardTagBlock)successBlock
               error:(FailBlock)errorBlock;
@end
