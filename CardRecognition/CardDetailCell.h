//
//  CardDetailCell.h
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardDetailCell : UITableViewCell
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;

-(void)setupTitle:(NSString *)title andContent:(NSString *)content;
@end
