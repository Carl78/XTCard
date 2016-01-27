//
//  Industry.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/10.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Industry : NSObject

@property(nonatomic, strong) NSNumber *Id;
@property(nonatomic, copy) NSString *Words;
@property(nonatomic, copy) NSString *Createtime;
@property(nonatomic, copy) NSString *Createuser;
@property(nonatomic, strong) NSArray *Businesscards;
@end
