//
//  OtherHttpRequestService.h
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "HttpRequestService.h"

typedef void (^SuccessBlock)(NSString *strToken);
typedef void (^FailBlock)(NSString *strFail);
@interface OtherHttpRequestService : HttpRequestService
- (void)getAllIndustry:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getAllCardTag:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
- (void)getAllArea:(SuccessBlock)successBlock
             error:(FailBlock)errorBlock;

-(void)getGroupByUserId:(NSNumber *)userId
                success:(SuccessBlock)successBlock
                  error:(FailBlock)errorBlock;

-(void)getPlistVersion:(SuccessBlock)successBlock error:(FailBlock)errorBlock;
@end
