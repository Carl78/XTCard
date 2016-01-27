//
//  DBOperation.h
//  CardRecognition
//
//  Created by bournejason on 15/5/10.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDatabase.h"
#import "DBGroup.h"
#import "DBCard.h"
#import "DBCardListItem.h"

@interface DBOperation : NSObject{
    FMDatabase *dataBase;
}
-(NSMutableArray *)QueryGroup;
-(void)InsertGroup:(NSString *)name;
-(void)DeleteGroup:(NSString *)gid;
-(void)UpdateGroup:(NSString *)name id:(NSString *)gid;

-(void)CreateCard;
-(NSMutableArray *)getCardList;
-(NSMutableArray *)getCardListBySearchText:(NSString *)text;
-(DBCard *)getCardInfoById:(NSInteger *)cid;
-(void)InsertCard:(DBCard *)card;
-(void)DeleteCard:(NSString *)cid;
-(void)UpdateCard:(DBCard *)card;

-(NSMutableArray *)getCardListByShard;
-(void)UpdateCardShard:(NSArray *)shardArray;
-(void)UpdateCardSaveState:(NSNumber *)cid;
-(BOOL)getCardyName:(NSString *)name phone:(NSString *)mobile company:(NSString *)com;

-(NSString *)QueryGroupById:(NSString *)gid;

-(BOOL)CheckColumn:(NSString *)cName inTable:(NSString *)tName;
-(void)UpdateDB104;

@end
