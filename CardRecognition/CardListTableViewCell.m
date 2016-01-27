//
//  CardListTableViewCell.m
//  CardRecognition
//
//  Created by bournejason on 15/6/2.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardListTableViewCell.h"
#define kRightMenuWidth 60 //右菜单宽度
@implementation CardListTableViewCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int width = [UIScreen mainScreen].bounds.size.width;
        
        //1 cell图标
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(10, 20, 50, 35);
        self.logoImageView = imageView;
        [self.contentView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc]init];
        name.frame = CGRectMake(70, 5, 80, 30);
        name.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:16];;
        self.nameLabel = name;
        [self.contentView addSubview:name];
        
        UILabel *title = [[UILabel alloc]init];
        title.frame = CGRectMake(70, 35, width-65-kRightMenuWidth, 20);
        title.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.titleLabel = title;
        [self.contentView addSubview:title];
        
        UILabel *company = [[UILabel alloc]init];
        company.frame = CGRectMake(70, 55, width-65-kRightMenuWidth, 20);
        company.font = [UIFont fontWithName:@"Helvetica" size:12];
        self.companyLabel = company;
        [self.contentView addSubview:company];
        
        
        
    }
    return self;
}


@end
