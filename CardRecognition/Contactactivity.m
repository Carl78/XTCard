//
//  Contactactivity.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "Contactactivity.h"

@implementation Contactactivity

-(NSDictionary *)getDictionaryData{
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    
    [dict setObject:[NSString stringWithFormat:@"%@",self.Id] forKey:@"Id"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.Activitytype] forKey:@"Activitytype"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.Activitytime] forKey:@"Activitytime"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.Content] forKey:@"Content"];
    [dict setObject:[NSString stringWithFormat:@"%@",self.Cardid] forKey:@"Cardid"];
    
    return dict;
}
@end
