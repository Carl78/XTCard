//
//  CardListModel.h
//  CardRecognition
//
//  Created by bournejason on 15/6/2.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "JSONModel.h"
#import "CardModel.h"

@interface CardListModel : JSONModel
@property (assign,nonatomic) NSInteger CurrentPageIndex;//地区id
@property (strong,nonatomic) NSArray<CardModel> *Items;
@property (assign,nonatomic) NSInteger PageSize;
@property (assign,nonatomic) NSInteger TotalItemCount;
@end
