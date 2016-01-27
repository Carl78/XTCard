//
//  Contactactivity.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Contactactivity : NSObject

@property (nonatomic) NSNumber *Id;
@property (nonatomic) NSNumber *Activitytype;
@property (nonatomic, copy) NSString *Activitytime;
@property (nonatomic, copy) NSString *ActivitypeName;
@property (nonatomic, copy) NSString *Content;
@property (nonatomic) NSNumber *Cardid;
@property (nonatomic, copy) NSString *Activitytype1;
@property (nonatomic, copy) NSString *Createtime;
@property (nonatomic, copy) NSString *StrActivitytime;

-(NSDictionary *)getDictionaryData;
@end
