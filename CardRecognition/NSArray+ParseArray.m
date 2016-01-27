//
//  NSArray+ParseArray.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "NSArray+ParseArray.h"

@implementation NSArray (ParseArray)

+(NSString *)numberArrayToString:(NSArray *)numberArr{
    
    NSMutableString *string = [NSMutableString stringWithString:@""];
    
    NSMutableArray *tempArr = [@[@"["] mutableCopy];
    if (numberArr.count > 0) {
        for (NSNumber *num in numberArr) {
            NSString *numStr = [NSString stringWithFormat:@"%@",num];
            [tempArr addObject:numStr];
            [tempArr addObject:@","];
        }
        
        [tempArr removeLastObject];
    }
    
    [tempArr addObject:@"]"];
    
    for (NSString *str in tempArr) {
        [string appendString:str];
    }
    
    return string;
}
@end
