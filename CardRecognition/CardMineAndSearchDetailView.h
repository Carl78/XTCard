//
//  CardMineAndSearchDetailView.h
//  CardRecognition
//
//  Created by bournejason on 15/6/11.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardModel;
@interface CardMineAndSearchDetailView : UIView
@property (nonatomic, strong) CardModel *card;
@property (nonatomic, weak) UIViewController *parentViewController;

-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)card;

-(void)setCardEditting:(BOOL)isEdittingCard;
@end
