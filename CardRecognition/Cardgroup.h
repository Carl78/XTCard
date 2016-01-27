//
//  Cardgroup.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/10.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cardgroup : NSObject

@property(nonatomic, strong) NSNumber *Id;
@property(nonatomic, strong) NSNumber *Userid;
@property(nonatomic, copy) NSString *Createtime;
@property(nonatomic, copy) NSString *Name;
@property(nonatomic, strong) NSArray *GourpidBusinesscards;
@end
