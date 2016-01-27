//
//  ActivityTypeObject.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ActivityTypeObject : NSObject
@property(nonatomic, assign) int Closevalue;
@property(nonatomic, strong) NSArray *Contactactivities;
@property(nonatomic, copy) NSString *Createtime;
@property(nonatomic) NSNumber *Id;
@property(nonatomic, copy) NSString *Name;
@end
