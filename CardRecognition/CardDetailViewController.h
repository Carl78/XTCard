//
//  CardDetailViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/5/28.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardDetailViewController : UIViewController<UIAlertViewDelegate>
@property(nonatomic) BOOL isEdittingCard;
-(id)initWithFrame:(CGRect)frame andCardModel:(NSInteger )cardID;
@end
