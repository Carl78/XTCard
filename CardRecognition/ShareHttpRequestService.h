//
//  ShareHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);
@interface ShareHttpRequestService : HttpRequestService

//- (void)deleteCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;

//- (void)getCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock;

- (void)getCardWithCompangOrName:(NSString *)companyOrName
                      pageNumber:(int)page pageSize:(int)size
                       sortField:(int)sort userId:(int)ID
                        hasShare:(BOOL)hasShare
                         success:(SuccessBlock)successBlock
                           error:(FailBlock)errorBlock;

/** 名片分享
 *  @param  userIds 分享用户编号集合
 *  @param  cardIds 名片编号集合
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)addCardshareByUserIds:(NSArray *)userIds
                     cardIds:(NSArray *)cardIds
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock;

/** 取消分享
 *  @param  cardIds 名片编号集合
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)cancelCardShareByCardIds:(NSArray *)cardIds
                        success:(SuccessBlock)successBlock
                          error:(FailBlock)errorBlock;

/** 获取所有用户信息
 *  @param  name 检索的用户名
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)getUserByName:(NSString*)name
            cardID:(NSString*)cardid
             success:(SuccessBlock)successBlock
               error:(FailBlock)errorBlock;

-(void)getSharedUserByCardId:(NSString *)cardId username:(NSString *)name success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock;
-(void)deleteSharedUserByCardId:(NSArray *)cardIds success:(SuccessBlock)successBlock
                          error:(FailBlock)errorBlock;

@end
