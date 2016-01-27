//
//  SyncHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"
typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);
@interface SyncHttpRequestService : HttpRequestService

-(void)sysnCardInfo:(NSArray *)items
            success:(SuccessBlock)successBlock
          failBlock:(FailBlock)errorBlock;
@end
