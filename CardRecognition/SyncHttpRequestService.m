//
//  SyncHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "SyncHttpRequestService.h"
#import "CardModel.h"
#import "JSONKit.h"

@implementation SyncHttpRequestService

-(void)sysnCardInfo:(NSArray *)items success:(SuccessBlock)successBlock failBlock:(FailBlock)errorBlock
{
    NSMutableArray *cardArr = [NSMutableArray array];
    
    for (CardModel *card in items) {
        NSDictionary *cardDic = [self getBusinessCard:card];
        [cardArr addObject:cardDic];
    }
    NSString *jsonString = [cardArr JSONString];
    
    NSMutableDictionary *dicPara = [@{@"items":jsonString} mutableCopy];
    [self postRequestToServer:@"SyncCardInfo" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(NSDictionary *)getBusinessCard:(CardModel *)card
{
    if (card.Base64Image==nil) {
        card.Base64Image = @"";
    }
    
    card.Base64Image = [card.Base64Image stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
    
    NSMutableDictionary *dict=
    [@{@"Id":@"0",
       //       @"Gourpid":@"",
       @"Telephone":[NSString stringWithFormat:@"%@",card.Telephone],
       @"syncState":@"0",
       //       @"companyid":@"0",
       @"State":[NSString stringWithFormat:@"%@",@"1"],
       //       @"Areaid":@"0",
       @"Maintenanceuser":[NSString stringWithFormat:@"%@",card.Maintenanceuser],
       @"Mobilphone":[NSString stringWithFormat:@"%@",card.Mobilphone],
       @"GroupName":[NSString stringWithFormat:@"%@",card.GroupName],
       @"Base64Image":[NSString stringWithFormat:@"%@",card.Base64Image],
       //@"Base64Image":[NSString stringWithFormat:@"%@",@""],
       @"Createuser":[NSString stringWithFormat:@"%@",card.Createuser],
       //       @"Industryid":@"0",
       @"Fax":[NSString stringWithFormat:@"%@",card.Fax],
       @"CompanyName":[NSString stringWithFormat:@"%@",card.CompanyName],
       @"CardidPlusattributeofcards":@[],
       @"Name":[NSString stringWithFormat:@"%@",card.Name],
       @"Email":[NSString stringWithFormat:@"%@",card.Email],
       @"Address":[NSString stringWithFormat:@"%@",card.Address],
       @"Position":[NSString stringWithFormat:@"%@",card.Position],
       @"Remark":[NSString stringWithFormat:@"%@",card.Remark],
       @"CardidPlusattributeofcards":@""} mutableCopy];
    
    //    if (card.Areaid == nil) {
    //        [dict setObject:@"0" forKey:@"Areaid"];
    //    }
    //    if (card.Gourpid == nil) {
    //        [dict setObject:@"0" forKey:@"Gourpid"];
    //    }
    
    return dict;
}
@end
