//
//  CardHttpRequestService.m
//  CardRecognition
//
//  Created by bournejason on 15/6/1.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardHttpRequestService.h"
#import "MJRefresh.h"
#import "RMMapper.h"
#import "JSONKit.h"

@implementation CardHttpRequestService
- (void)addCardWithUserID:(NSString *)uID groupName:(NSString *)name success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    
}
- (void)deleteCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    NSMutableDictionary *dicPara = [@{@"id":ID} mutableCopy];
    [self postRequestToServer:@"DeleteCard" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
- (void)getCardByID:(NSString *)ID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    
}
- (void)getCardWithCompangOrName:(NSString *)companyOrName pageNumber:(int)page pageSize:(int)size sortField:(int)sort userId:(int)ID hasShare:(BOOL)hasShare success:(SuccessBlock)successBlock error:(FailBlock)errorBlock{
    
    NSString *hasShareString;
    if(hasShare==YES){
        hasShareString = @"true";
    }else{
        hasShareString = @"false";
    }
    
    NSString *userIDString = [NSString stringWithFormat:@"%d",ID];
    
    NSMutableDictionary *dicPara = [@{@"companyOrName":companyOrName
                                      ,@"pageNumber":[NSNumber numberWithInt:page],@"pageSize":[NSNumber numberWithInt:size],@"sortField":[NSNumber numberWithInt:sort],@"userId":userIDString,@"hasShare":hasShareString} mutableCopy];
    [self postRequestToServer:@"GetCard" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}

-(void)addBusinessCardByItem:(CardModel *)item
                     success:(SuccessBlock)successBlock
                       error:(FailBlock)errorBlock
{
    NSString *c_jsonString = [[self getBusinessCard:item] JSONString];
    
    NSMutableDictionary *dicPara = [@{@"card":c_jsonString} mutableCopy];
    
    [self postRequestToServer:@"AddBusinessCard" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
-(NSDictionary *)getBusinessCard:(CardModel *)card
{
    NSMutableArray *plusArr = [NSMutableArray array];
    NSArray *pluses = card.CardidPlusattributeofcards;
    
    for (CardPlus *plus in pluses) {
        NSDictionary *thePlus =
        @{@"Tagid":[NSString stringWithFormat:@"%@",plus.Tagid],
          @"Optionid":[NSString stringWithFormat:@"%@",plus.Optionid],
          @"Cardid":[NSString stringWithFormat:@"%@",plus.Cardid],
          };
        
        [plusArr addObject:thePlus];
    }
    
    
    NSMutableDictionary *dict=
    [@{@"Id":card.Id,
       @"syncState":@"0",
       @"State":[NSString stringWithFormat:@"%@",@"1"],
       @"Areaid":[NSString stringWithFormat:@"%@",card.Areaid],
       @"Gourpid":[NSString stringWithFormat:@"%@",card.Gourpid],
       @"Industryid":[NSString stringWithFormat:@"%@",card.Industryid],
       @"Createuser":[NSString stringWithFormat:@"%@",card.Createuser],
       @"Maintenanceuser":[NSString stringWithFormat:@"%@",card.Maintenanceuser],
       @"CardidPlusattributeofcards":[NSArray arrayWithArray:plusArr]} mutableCopy];
    
    if (card.CompanyName) {
        [dict setObject:card.CompanyName forKey:@"CompanyName"];
    }
    
    if (card.Fax) {
        [dict setObject:card.Fax forKey:@"Fax"];
    }
    
    if (card.Address) {
        [dict setObject:card.Address forKey:@"Address"];
    }
    if (card.Name) {
        [dict setObject:card.Name forKey:@"Name"];
    }
    if (card.Position) {
        [dict setObject:card.Position forKey:@"Position"];
    }
    if (card.Email) {
        [dict setObject:card.Email forKey:@"Email"];
    }
    if (card.Mobilphone) {
        [dict setObject:card.Mobilphone forKey:@"Mobilphone"];
    }
    if (card.Telephone) {
        [dict setObject:card.Telephone forKey:@"Telephone"];
    }
    if (card.Remark) {
        [dict setObject:card.Remark forKey:@"Remark"];
    }
    
//    [@{@"CompanyName":[NSString stringWithFormat:@"%@",card.CompanyName],
////       @"Createuser":[NSString stringWithFormat:@"%@",card.Createuser],
////       @"Areaid":[NSString stringWithFormat:@"%@",card.Areaid],
//       @"Fax":[NSString stringWithFormat:@"%@",card.Fax],
////       @"CardidPlusattributeofcards":[NSArray arrayWithArray:plusArr],
//       @"Address":[NSString stringWithFormat:@"%@",card.Address],
//       @"Name":[NSString stringWithFormat:@"%@",card.Name],
//       @"Position":[NSString stringWithFormat:@"%@",card.Position],
//       @"Email":[NSString stringWithFormat:@"%@",card.Email],
////       @"Gourpid":[NSString stringWithFormat:@"%@",card.Gourpid],
////       @"Industryid":[NSString stringWithFormat:@"%@",card.Industryid],
////       @"Maintenanceuser":[NSString stringWithFormat:@"%@",card.Maintenanceuser],
//       @"Mobilphone":[NSString stringWithFormat:@"%@",card.Mobilphone],
//       @"Telephone":[NSString stringWithFormat:@"%@",card.Telephone],
//       @"Remark":[NSString stringWithFormat:@"%@",card.Remark]} mutableCopy];
    
    if (card.Areaid == nil) {
        [dict setObject:@"0" forKey:@"Areaid"];
    }
    if (card.Gourpid == nil) {
        [dict setObject:@"0" forKey:@"Gourpid"];
    }
    if (card.Industryid == nil) {
        [dict setObject:@"0" forKey:@"Industryid"];
    }
    
    return dict;
}


-(void)getBusinessCardById:(NSNumber *)cardID success:(SuccessBlock)successBlock error:(FailBlock)errorBlock
{
    
    NSMutableDictionary *dicPara = [@{@"id":cardID} mutableCopy];
    
    [self postRequestToServer:@"GetBusinessCardById" dicParams:dicPara success:^(NSString *responseString) {
        successBlock(responseString);
    } error:^(NSInteger errorCode, NSString *errorMessage) {
        errorBlock(errorMessage);
        
    }];
}
@end
