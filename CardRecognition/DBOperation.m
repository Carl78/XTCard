//
//  DBOperation.m
//  CardRecognition
//
//  Created by bournejason on 15/5/10.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "DBOperation.h"


#define kDataBaseName @"SXCardDB"

@implementation DBOperation

-(id)init{
    self = [super init];
    if (self!=nil) {
        [self CreateGroup];
        [self CreateCard];
        [self UpdateDB104];
    }
    
    return self;
}

- (NSString*) getPath:(NSString *)name{
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) ;
    return [[paths objectAtIndex:0]stringByAppendingPathComponent:name] ;
}

#pragma mark group

-(void)CreateGroup
{
    dataBase = [FMDatabase databaseWithPath:[self getPath:kDataBaseName]];
    if (![dataBase open])
        NSLog(@"OPEN FAIL");
    [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS t_group (id INTEGER PRIMARY KEY AUTOINCREMENT,name text)"];
    [dataBase close];
}

-(NSMutableArray *)QueryGroup
{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        FMResultSet *rs = [dataBase executeQuery:@"SELECT * FROM t_group"];
        while ([rs next]){
            DBGroup *group = [[DBGroup alloc]init];
            group.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            group.name = [rs stringForColumn:@"name"];
            [recordArray addObject: group];
        }
        [rs close];
        [dataBase close];
    }
    return recordArray;
}

-(void)UpdateGroup:(NSString *)name id:(NSString *)gid
{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"UPDATE t_group SET name = ? WHERE id = ?",name,gid];
        [dataBase commit];
        [dataBase close];
    }
    
}

-(void)DeleteGroup:(NSString *)gid
{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"Delete FROM t_group WHERE id = ?",gid];
        [dataBase commit];
        [dataBase close];
    }
    
}

-(void)InsertGroup:(NSString *)name
{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"INSERT INTO t_group VALUES (null,?)",name];
        [dataBase commit];
        [dataBase close];
    }
    
}
-(NSString *)QueryGroupById:(NSString *)gid
{
    //获取数据
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_group WHERE id=%@",gid];
    
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        FMResultSet *rs = [dataBase executeQuery:sql];
        while ([rs next]){
            
            NSString *name = [rs stringForColumn:@"name"];
            [rs close];
            [dataBase close];
            return name;
        }
        [rs close];
        [dataBase close];
    }
    return nil;
}

#pragma mark card
-(void)CreateCard{
    dataBase = [FMDatabase databaseWithPath:[self getPath:kDataBaseName]];
    if (![dataBase open])
        NSLog(@"OPEN FAIL");
    [dataBase executeUpdate:@"CREATE TABLE IF NOT EXISTS t_card (id INTEGER PRIMARY KEY AUTOINCREMENT,name text,sur_name text,post_name text,job_tel text,home_tel text,fax text,mobile text,mail text,url text,title text,company text,address text,post_code text,note text,age text,department text,date text,birthday text,pic_name text,create_time datetime,group_id INTEGER,is_shared INTEGER)"];
    [dataBase close];
}
-(NSMutableArray *)getCardList{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        FMResultSet *rs = [dataBase executeQuery:@"SELECT id,name,title,company,pic_name,create_time,group_id, is_saved FROM t_card"];
        while ([rs next]){
            DBCardListItem *item = [[DBCardListItem alloc]init];
            item.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            item.name = [rs stringForColumn:@"name"];
            item.title = [rs stringForColumn:@"title"];
            item.company = [rs stringForColumn:@"company"];
            item.pic_name = [rs stringForColumn:@"pic_name"];
            item.create_time = [rs stringForColumn:@"create_time"];
            item.gid = [NSNumber numberWithInt:[rs intForColumn:@"group_id"]];
            item.is_saved = [NSNumber numberWithInt:[rs intForColumn:@"is_saved"]];
            [recordArray addObject: item];
        }
        [rs close];
        [dataBase close];
    }
    return recordArray;
}

-(NSMutableArray *)getCardListBySearchText:(NSString *)text{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        //NSString *sql = [NSString stringWithFormat:@"SELECT id,name,title,company,pic_name,create_time,group_id FROM t_card WHERE name like %%%@%% OR company like %%%@%%",text,text];
        NSString *sql = [NSString stringWithFormat:@"SELECT id,name,title,company,pic_name,create_time,group_id,is_saved FROM t_card WHERE name like '%%%@%%' or company like '%%%@%%'",text, text];
        FMResultSet *rs = [dataBase executeQuery:sql];
        while ([rs next]){
            DBCardListItem *item = [[DBCardListItem alloc]init];
            item.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            item.name = [rs stringForColumn:@"name"];
            item.title = [rs stringForColumn:@"title"];
            item.company = [rs stringForColumn:@"company"];
            item.pic_name = [rs stringForColumn:@"pic_name"];
            item.create_time = [rs stringForColumn:@"create_time"];
            item.gid = [NSNumber numberWithInt:[rs intForColumn:@"group_id"]];
            item.is_saved = [NSNumber numberWithInt:[rs intForColumn:@"is_saved"]];
            [recordArray addObject: item];
        }
        [rs close];
        [dataBase close];
    }
    return recordArray;
}

-(NSMutableArray *)getCardListByShard{
    //获取数据
    NSMutableArray *recordArray = [[NSMutableArray alloc]init];
    
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        //NSString *sql = [NSString stringWithFormat:@"SELECT id,name,title,company,pic_name,create_time,group_id FROM t_card WHERE name like %%%@%% OR company like %%%@%%",text,text];
        NSString *sql = [NSString stringWithFormat:@"SELECT id,name,title,company,pic_name,create_time,group_id FROM t_card WHERE is_shared=0"];
        FMResultSet *rs = [dataBase executeQuery:sql];
        while ([rs next]){
            DBCardListItem *item = [[DBCardListItem alloc]init];
            item.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            item.name = [rs stringForColumn:@"name"];
            item.title = [rs stringForColumn:@"title"];
            item.company = [rs stringForColumn:@"company"];
            item.pic_name = [rs stringForColumn:@"pic_name"];
            item.create_time = [rs stringForColumn:@"create_time"];
            item.gid = [NSNumber numberWithInt:[rs intForColumn:@"group_id"]];
            [recordArray addObject: item];
        }
        [rs close];
        [dataBase close];
    }
    return recordArray;
}

-(void)UpdateCardShard:(NSArray *)shardArray{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        for (NSNumber *cardID in shardArray) {
            [dataBase executeUpdate:@"UPDATE t_card SET is_shared=1 WHERE id=?",cardID];
        }
        [dataBase close];
    }
}

// 更新是否同步到本地通讯录状态
-(void)UpdateCardSaveState:(NSNumber *)cid{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase executeUpdate:@"UPDATE t_card SET is_saved=1 WHERE id=?",cid];
        [dataBase close];
    }
}

-(NSMutableArray *)getCardListByGroupId:(NSInteger *)gid{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    DBCard *card = [[DBCard alloc]init];
    
    if ([dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_card WHERE group_id=%d",gid];
        FMResultSet *rs = [dataBase executeQuery:sql];
        if ([rs next]){
            card.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            card.name = [rs stringForColumn:@"name"];
            card.sur_name = [rs stringForColumn:@"sur_name"];
            card.post_name = [rs stringForColumn:@"post_name"];
            card.job_tel = [rs stringForColumn:@"job_tel"];
            card.home_tel = [rs stringForColumn:@"home_tel"];
            card.fax = [rs stringForColumn:@"fax"];
            card.mobile = [rs stringForColumn:@"mobile"];
            card.mail = [rs stringForColumn:@"mail"];
            card.url = [rs stringForColumn:@"url"];
            card.title = [rs stringForColumn:@"title"];
            card.company = [rs stringForColumn:@"company"];
            card.address = [rs stringForColumn:@"address"];
            card.post_code = [rs stringForColumn:@"post_code"];
            card.note = [rs stringForColumn:@"note"];
            card.age = [rs stringForColumn:@"age"];
            card.department = [rs stringForColumn:@"department"];
            card.date = [rs stringForColumn:@"date"];
            card.birthday = [rs stringForColumn:@"birthday"];
            card.pic_name = [rs stringForColumn:@"pic_name"];
            card.create_time = [rs stringForColumn:@"create_time"];
            card.gid = [NSNumber numberWithInt:[rs intForColumn:@"group_id"]];
        }else{
            
            return nil;
        }
        [rs close];
        [dataBase close];
    }
    
    return card;
}
-(DBCard *)getCardInfoById:(NSInteger *)cid{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    DBCard *card = [[DBCard alloc]init];

    if ([dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_card WHERE id=%d",cid];
        FMResultSet *rs = [dataBase executeQuery:sql];
        if ([rs next]){
            card.Id = [NSNumber numberWithInt:[rs intForColumn:@"id"]];
            card.name = [rs stringForColumn:@"name"];
            card.sur_name = [rs stringForColumn:@"sur_name"];
            card.post_name = [rs stringForColumn:@"post_name"];
            card.job_tel = [rs stringForColumn:@"job_tel"];
            card.home_tel = [rs stringForColumn:@"home_tel"];
            card.fax = [rs stringForColumn:@"fax"];
            card.mobile = [rs stringForColumn:@"mobile"];
            card.mail = [rs stringForColumn:@"mail"];
            card.url = [rs stringForColumn:@"url"];
            card.title = [rs stringForColumn:@"title"];
            card.company = [rs stringForColumn:@"company"];
            card.address = [rs stringForColumn:@"address"];
            card.post_code = [rs stringForColumn:@"post_code"];
            card.note = [rs stringForColumn:@"note"];
            card.age = [rs stringForColumn:@"age"];
            card.department = [rs stringForColumn:@"department"];
            card.date = [rs stringForColumn:@"date"];
            card.birthday = [rs stringForColumn:@"birthday"];
            card.pic_name = [rs stringForColumn:@"pic_name"];
            card.create_time = [rs stringForColumn:@"create_time"];
            card.gid = [NSNumber numberWithInt:[rs intForColumn:@"group_id"]];

        }else{
            
            return nil;
        }
        [rs close];
        [dataBase close];
    }
    
    return card;
}
-(void)InsertCard:(DBCard *)card{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"INSERT INTO t_card VALUES (null,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,0,0)",card.name,card.sur_name,card.post_name,card.job_tel,card.home_tel,card.fax,card.mobile,card.mail,card.url,card.title,card.company,card.address,card.post_code,card.note,card.age,card.department,card.date,card.birthday,card.pic_name,card.create_time,card.gid];
        [dataBase commit];
        [dataBase close];
    }
}
-(void)DeleteCard:(NSString *)cid{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"Delete FROM t_card WHERE id = ?",cid];
        [dataBase commit];
        [dataBase close];
    }
}
-(void)UpdateCard:(DBCard *)card{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if ([dataBase open]) {
        [dataBase beginTransaction];
        [dataBase executeUpdate:@"UPDATE t_card SET name=?,sur_name=?,post_name=?,job_tel=?,home_tel=?,fax=?,mobile=?,mail=?,url=?,title=?,company=?,address=?,post_code=?,note=?,age=?,department=?,date=?,birthday=?,pic_name=?,create_time=?,group_id=? WHERE id=?",card.name,card.sur_name,card.post_name,card.job_tel,card.home_tel,card.fax,card.mobile,card.mail,card.url,card.title,card.company,card.address,card.post_code,card.note,card.age,card.department,card.date,card.birthday,card.pic_name,card.create_time,card.gid,card.Id];
        [dataBase commit];
        [dataBase close];
    }
}

-(BOOL)getCardyName:(NSString *)name phone:(NSString *)mobile company:(NSString *)com{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    
    if ([dataBase open]) {
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM t_card WHERE name='%@' AND mobile='%@' AND company='%@'",name,mobile,com];
        FMResultSet *rs = [dataBase executeQuery:sql];
        if ([rs next]){
            return YES;
        }else{
            return NO;
        }
    }
    return NO;
}

#pragma mark - DB Update

-(BOOL)CheckDB:(FMDatabase *)db Column:(NSString *)cName inTable:(NSString *)tName
{
    if ([db open]) {
        NSString *sql = [NSString stringWithFormat:@"select * from sqlite_master where name='%@' and sql like '%%%@%%'",tName, cName];
        FMResultSet *rs = [db executeQuery:sql];
        if ([rs next]){
            [db close];
            return YES;
        }else{
            [db close];
            return NO;
        }
    }
    return NO;
}

/* 1.0.4 更新
表t_card增加is_saved字段
 */
-(void)UpdateDB104
{
    dataBase = [[FMDatabase alloc]initWithPath:[self getPath:kDataBaseName]];
    if(![self CheckDB:dataBase Column: @"is_saved" inTable:@"t_card"])
    {
        if ([dataBase open]) {
            [dataBase executeUpdate:@"ALTER TABLE t_card ADD is_saved INTEGER DEFAULT 0"];
            [dataBase close];
        }
    }
    else{
//        if ([dataBase open]) {
//            [dataBase executeUpdate:@"UPDATE t_card SET is_saved = 0"];
//            [dataBase close];
//        }
    }
}



@end
