//
//  CardChangeView.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/5.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OperationBlock)();

@interface CardChangeView : UIView
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

- (IBAction)clearContent:(id)sender;

-(void)didDeleteOperation:(OperationBlock)deleteBlock;
@end
