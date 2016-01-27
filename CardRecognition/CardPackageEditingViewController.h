//
//  CardEdittingViewController.h
//  CardRecognition
//
//  名片数据编辑页面
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OperateBlock)(NSString *newValue);

@interface CardPackageEditingViewController : UIViewController


-(id)initWithName:(NSString *)name andTargetValue:(NSString *)value kcount:(int)count;
-(void)setCompleteOpertion:(OperateBlock)operation;
-(void)didDeleteOpertion:(OperateBlock)operation;

@property(nonatomic,assign)int keyCount;
@end
