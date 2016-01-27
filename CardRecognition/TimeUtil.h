//
//  TimeUtil.h
//  MoreSDKDemo
//
//  Created by sunshinek31 on 15/1/26.
//  Copyright (c) 2015年 moneymoremore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimeUtil : NSObject
+(NSString *)getCurrentTime;
+(NSString *)getTargetTime:(NSDate *)targetDate;
+ (NSString *) newDate:(NSInteger) month from:(NSDate *)date;
+(NSDate *)getTargetDate:(NSString *)tragetDate;
@end
