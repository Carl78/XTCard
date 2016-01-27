//
//  CardGroupEditingViewController.h
//  CardRecognition
//
//  Created by bournejason on 15/11/3.
//  Copyright © 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OperateBlock)(NSString *newValue);

@interface CardGroupEditingViewController : UIViewController

-(id)initWithName:(NSString *)name andTargetValue:(NSString *)value;
-(void)setCompleteOpertion:(OperateBlock)operation;
-(void)didDeleteOpertion:(OperateBlock)operation;

@end
