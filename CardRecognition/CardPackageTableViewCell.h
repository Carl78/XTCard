//
//  CardPackageTableViewCell.h
//  CardRecognition
//
//  Created by bournejason on 15/5/27.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardPackageTableViewCell : UITableViewCell
@property (nonatomic,weak) UILabel *titleLabel;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UILabel *companyLabel;
@property (nonatomic,weak) UIImageView *cardImageView;
@property (nonatomic,weak) UIImageView *cardBookImageView;
@end
