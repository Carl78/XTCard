//
//  UITextField+Other.m
//  CardRecognition
//
//  Created by bournejason on 15/6/9.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "UITextField+Other.h"
#import <objc/runtime.h>

@implementation UITextField (Other)
@dynamic idx;

- (NSString *)idx
{
    NSString *idx = objc_getAssociatedObject(self, @"kUIButtonIdxKey");
    return idx;
}

- (void)setIdx:(NSString *)idx
{
    objc_setAssociatedObject(self, @"kUIButtonIdxKey", idx, OBJC_ASSOCIATION_RETAIN);
}
@end
