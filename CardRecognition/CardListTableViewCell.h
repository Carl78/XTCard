//
//  CardListTableViewCell.h
//  CardRecognition
//
//  Created by bournejason on 15/6/2.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardListTableViewCell : UITableViewCell
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UILabel *companyLabel;
@property (nonatomic,weak) UIImageView *logoImageView;
@end
