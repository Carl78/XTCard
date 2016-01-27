//
//  CardTag.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardTag.h"
#import "TagidCardtagvalue.h"
#import "RMMapper.h"

@implementation CardTag

-(void)setTagidCardtagvalues:(NSArray *)TagidCardtagvalues{
    NSMutableArray *temp = [NSMutableArray array];
    for (id obj in TagidCardtagvalues) {
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            
            TagidCardtagvalue *tag = [RMMapper objectWithClass:[TagidCardtagvalue class] fromDictionary:obj];
            [temp addObject:tag];
        }else{
            [temp addObject:obj];
        }
        
        
        
    }
    
    _TagidCardtagvalues = [NSArray arrayWithArray:temp];
    
//    _TagidCardtagvalues = TagidCardtagvalues;
}

@end
