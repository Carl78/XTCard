//
//  CardManageDetailViewController.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardModel;

@interface CardManageDetailViewController : UIViewController
@property(nonatomic) BOOL isEdittingCard;

-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)cardModel;
@end
