//
//  SharedCard.h
//  CardRecognition
//
//  Created by bournejason on 15/11/2.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedCard : NSObject
@property(nonatomic, strong) NSNumber *Id;
@property(nonatomic, strong) NSString *businesscard;
@property(nonatomic, strong) NSString *Createtime;
@property(nonatomic, strong) NSNumber *Cardid;
@property(nonatomic, strong) NSNumber *Shareduser;
@property(nonatomic, strong) NSString *ShareUsername;

@end
