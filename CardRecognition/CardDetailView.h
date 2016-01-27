//
//  CardDetailView.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CardModel;

@interface CardDetailView : UIView
@property (nonatomic, strong) CardModel *card;
@property (nonatomic, weak) UIViewController *parentViewController;

-(id)initWithFrame:(CGRect)frame andCardModel:(CardModel *)card;

-(void)setCardEditting:(BOOL)isEdittingCard;

@end
