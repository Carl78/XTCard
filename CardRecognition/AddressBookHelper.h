//
//  AddressBookHelper.h
//  CardRecognition
//
//  Created by admin on 16/1/6.
//  Copyright © 2016年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressBookHelper : NSObject

+(void)CheckAddressBookAuthorization:(void (^)(bool isAuthorized))block;

@end
