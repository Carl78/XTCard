//
//  LeftMenuTableViewCell.m
//  CardRecognition
//  左边菜单的cell
//  Created by bournejason on 15/5/6.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "LeftMenuTableViewCell.h"

@implementation LeftMenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //1 cell图标
        UIImageView *icon = [[UIImageView alloc]init];
        icon.frame = CGRectMake(30, 10, 30, 25);
        self.iconImageView = icon;
        [self.contentView addSubview:icon];
        
        //2 cell标题
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(70, 8, 160, 30);
        label.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        self.titleLabel = label;
        
        [self.contentView addSubview:label];
        
    }
    
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
