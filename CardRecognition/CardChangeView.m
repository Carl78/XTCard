//
//  CardChangeView.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardChangeView.h"

@interface CardChangeView ()<UIAlertViewDelegate>
@property(nonatomic, copy) OperationBlock deleteBlock;
@end

@implementation CardChangeView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


- (IBAction)clearContent:(id)sender {
    
    //初始化AlertView
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"AlertViewTest"
                                                    message:@"message"
                                                   delegate:self
                                          cancelButtonTitle:@"取消"
                                          otherButtonTitles:@"确认",nil];
    //设置标题与信息，通常在使用frame初始化AlertView时使用
    alert.title = @"提示";
    alert.message = @"确定删除吗？";
    
    //这个属性继承自UIView，当一个视图中有多个AlertView时，可以用这个属性来区分
    alert.tag = 0;
    
    //显示AlertView
    [alert show];
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"clickButtonAtIndex:%d",buttonIndex);
    if(buttonIndex == 1){
        self.textField.text = nil;
        if (self.deleteBlock) {
            self.deleteBlock();
        }
    }
}

-(void)didDeleteOperation:(OperationBlock)deleteBlock{
    self.deleteBlock = [deleteBlock copy];
}

@end
