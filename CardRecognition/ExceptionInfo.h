//
//  ExceptionInfo.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/7.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExceptionInfo : NSObject
@property(nonatomic) id Code;
@property(nonatomic, copy) NSString *Info;
@property(nonatomic) NSNumber *Result;
@end
