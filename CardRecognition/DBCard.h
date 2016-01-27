//
//  DBCard.h
//  CardRecognition
//
//  Created by bournejason on 15/5/17.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCard : NSObject
@property (nonatomic,strong) NSNumber *Id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *sur_name;
@property (nonatomic,strong) NSString *post_name;
@property (nonatomic,strong) NSString *job_tel;
@property (nonatomic,strong) NSString *home_tel;
@property (nonatomic,strong) NSString *fax;
@property (nonatomic,strong) NSString *mobile;
@property (nonatomic,strong) NSString *mail;
@property (nonatomic,strong) NSString *url;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *post_code;
@property (nonatomic,strong) NSString *note;
@property (nonatomic,strong) NSString *age;
@property (nonatomic,strong) NSString *department;
@property (nonatomic,strong) NSString *date;
@property (nonatomic,strong) NSString *birthday;
@property (nonatomic,strong) NSString *pic_name;
@property (nonatomic,strong) NSString *create_time;
@property (nonatomic,strong) NSNumber *gid;
@property (nonatomic,strong) NSNumber *is_saved;

@end