//
//  ActivityHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
#import "Contactactivity.h"
typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);

@interface ActivityHttpRequestService : HttpRequestService

/** 更加名片id查询联系人活动
 *  @param  cardId 名片id
 *  @param  pageNumber 页数
 *  @param  pageSize 页面显示条数
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
- (void)getContactByCard:(NSString *)cardId
              pageNumber:(int)pageNumber
                pageSize:(int)pageSize
                 success:(SuccessBlock)successBlock
                   error:(FailBlock)errorBlock;

/** 获取活动类型
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)getActivityTypeListWithSuccess:(SuccessBlock)successBlock
                                error:(FailBlock)errorBlock;

/** 添加联系人活动
 *  @param  contivity  根据contivity.Id 来判断是新增还是修改 (0:新增, !0:修改)
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)addContactByContivity:(Contactactivity *)contivity
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock;

/** 删除联系人活动
 *  @param  contactId  活动编号
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)deleteContactByContactId:(NSNumber *)contactId
                        success:(SuccessBlock)successBlock
                          error:(FailBlock)errorBlock;
@end
