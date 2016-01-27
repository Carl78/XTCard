//
//  CardPackageDetailView.h
//  CardRecognition
//
//  Created by bournejason on 15/6/8.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBCard.h"
@interface CardPackageDetailView : UIView
@property (nonatomic, strong) DBCard *card;
@property (nonatomic, weak) UIViewController *parentViewController;

-(id)initWithFrame:(CGRect)frame andCardModel:(DBCard *)card;

-(void)setCardEditting:(BOOL)isEdittingCard;

//-(BOOL)checkCard;
@end
