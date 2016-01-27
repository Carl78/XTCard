//
//  CardPackageTableViewCell.m
//  CardRecognition
//
//  Created by bournejason on 15/5/27.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardPackageTableViewCell.h"
#define kRightMenuWidth 60 //右菜单宽度

@implementation CardPackageTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        int width = [UIScreen mainScreen].bounds.size.width;
        
        //1 cell图标
        UIImageView *imageView = [[UIImageView alloc]init];
        imageView.frame = CGRectMake(10, 20, 50, 35);
        self.cardImageView = imageView;
        [self.contentView addSubview:imageView];
        
        UILabel *name = [[UILabel alloc]init];
        name.frame = CGRectMake(70, 5, 80, 30);
        name.font = [UIFont fontWithName:@"Helvetica-BoldOblique" size:16];;
        self.nameLabel = name;
        [self.contentView addSubview:name];
        
        // 是否同步到通讯录的图标
        UIImageView *imageViewBook = [[UIImageView alloc]init];
        imageViewBook.frame = CGRectMake(150, 10, 20, 20);
        self.cardBookImageView = imageViewBook;
        [self.contentView addSubview:imageViewBook];
        
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

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
