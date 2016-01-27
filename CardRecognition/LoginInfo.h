//
//  LoginInfo.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LoginInfo : NSObject
@property(nonatomic, copy) NSString *ClientIP;
@property(nonatomic, copy) NSString *LastAccessTime;
@property(nonatomic, copy) NSString *LoginName;
@property(nonatomic, copy) NSString *LoginToken;
@property(nonatomic, copy) NSString *Nick;
@property(nonatomic, strong) NSNumber *PartmentID;
@property(nonatomic, strong) NSArray *PermissionList;
@property(nonatomic, strong) NSNumber *UserID;
@end
