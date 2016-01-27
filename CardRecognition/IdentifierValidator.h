//
//  IdentifierValidator.h
//  CardRecognition
//
//  Created by bournejason on 15/6/22.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    IdentifierTypeKnown = 0,
    IdentifierTypeZipCode,      //1
    IdentifierTypeEmail,        //2
    IdentifierTypePhone,        //3
    IdentifierTypeUnicomPhone,  //4
    IdentifierTypeQQ,           //5
    IdentifierTypeNumber,       //6
    IdentifierTypeString,       //7
    IdentifierTypeIdentifier,   //8
    IdentifierTypePassort,      //9
    IdentifierTypeCreditNumber, //10
    IdentifierTypeBirthday,     //11
    IdentifierTypeMobilePhone,
}IdentifierType;

@interface IdentifierValidator : NSObject
{
}

+ (BOOL) isValid:(IdentifierType) type value:(NSString*) value;

@end
