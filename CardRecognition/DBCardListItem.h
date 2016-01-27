//
//  DBCardListItem.h
//  CardRecognition
//
//  Created by bournejason on 15/5/17.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBCardListItem : NSObject
@property (nonatomic,strong) NSNumber *Id;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *company;
@property (nonatomic,strong) NSString *pic_name;
@property (nonatomic,strong) NSString *create_time;
@property (nonatomic,strong) NSNumber *gid;
@property (nonatomic,strong) NSNumber *is_saved;
@end
