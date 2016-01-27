//
//  ActivityManageView.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ActivityManageView : UIView
@property(nonatomic, weak) UIViewController *parentViewController;

-(void)configSourceDataWithCardId:(NSString *)cardId;
@end
