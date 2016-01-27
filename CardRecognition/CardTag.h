//
//  CardTag.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TagidCardtagvalue.h"

@interface CardTag : NSObject


@property(nonatomic, copy) NSString *Tagname;
@property(nonatomic, copy) NSString *TagValue;
@property(nonatomic, copy) NSString *TagValueString;
@property(nonatomic, copy) NSString *Createtime;
@property(nonatomic, strong) NSNumber *Id;
@property(nonatomic, strong) id Guid;
@property(nonatomic, strong) NSArray *TagidCardtagvalues;
@end
