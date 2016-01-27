//
//  User.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ExceptionInfo.h"
#import "LoginInfo.h"



@interface User : NSObject
@property(nonatomic, strong) ExceptionInfo *exceptionInfo;
@property(nonatomic, strong) LoginInfo *loginInfo;
@end



