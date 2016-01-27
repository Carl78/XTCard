//
//  TimeUtil.m
//  MoreSDKDemo
//
//  Created by sunshinek31 on 15/1/26.
//  Copyright (c) 2015年 moneymoremore. All rights reserved.
//

#import "TimeUtil.h"

@implementation TimeUtil
+(NSString *)getCurrentTime {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:[NSDate date]];
    return currentDateStr;
}

+(NSString *)getTargetTime:(NSDate *)targetDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currentDateStr = [dateFormatter stringFromDate:targetDate];
    return currentDateStr;
}

+ (NSString *)newDate:(NSInteger)month from:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [formatter stringFromDate:date];
    NSArray *yM = [time componentsSeparatedByString:@"-"];
    int year = [yM[0] intValue];
    int dmonth = [yM[1] intValue];
    
    NSDate *newDate;
    
    if (month >= 0){
        if (dmonth > month) {
            NSString *newTimeStr = [NSString stringWithFormat:@"%d-%ld-%d %d:%d:%d",year,(dmonth - month),01,00,00,00];
            newDate = [formatter dateFromString:newTimeStr];
        }else{
            NSString *newTimeStr = [NSString stringWithFormat:@"%d-%ld-%d %d:%d:%d",(year-1),(12-month+dmonth),01,00,00,00];
            newDate = [formatter dateFromString:newTimeStr];
        }
    }else{
        if (dmonth - month > 12) {
            NSString *newTimeStr = [NSString stringWithFormat:@"%d-%ld-%d %d:%d:%d",(year+1),(dmonth-month - 12),01,00,00,00];
            newDate = [formatter dateFromString:newTimeStr];
        }else{
            NSString *newTimeStr = [NSString stringWithFormat:@"%d-%ld-%d %d:%d:%d",(year),(dmonth-month),01,00,00,00];
            newDate = [formatter dateFromString:newTimeStr];
        }
    }
    
    
    
    return [formatter stringFromDate:newDate];
}

+(NSDate *)getTargetDate:(NSString *)tragetDate{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [dateFormatter dateFromString:tragetDate];
    return date;
}
@end
