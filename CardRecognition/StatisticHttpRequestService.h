//
//  StatisticHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"

typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);

@interface StatisticHttpRequestService : HttpRequestService

/** 名片统计(折线图)
 *  @param  userID 用户id(如果为0则统计系统)
 *  @param  analyType 统计类型 1：按月统计，2：按天统计
 *  @param  startDate 统计开始时间
 *  @param  endDate 统计结束时间
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)getCardGrowthByUserID:(NSNumber *)userID
                   analyType:(NSNumber *)analyType
                   startDate:(NSString *)startDate
                     endDate:(NSString *)endDate
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock;

/** 名片统计(分布图)
 *  @param  userID 用户id(如果为0则统计系统)
 *  @param  section 1：按照行业统计；2：代表按照地区统计
 *  @param  successBlock 接口请求成功回调block
 *  @param  errorBlock  接口请求失败回调block
 */
-(void)getCardPieByUserID:(NSNumber *)userID
                  section:(NSNumber *)section
                  success:(SuccessBlock)successBlock
                    error:(FailBlock)errorBlock;

@end
