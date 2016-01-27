//
//  ManualAddCardTableViewCell.m
//  CardRecognition
//
//  Created by bournejason on 15/5/18.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "ManualAddCardTableViewCell.h"

@implementation ManualAddCardTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //1 cell图标
        UILabel *title = [[UILabel alloc]init];
        title.frame = CGRectMake(10, 5, 50, 30);
        self.titleLabel = title;
        [self.contentView addSubview:title];
        
        //2 cell标题
        UITextField *value = [[UITextField alloc]init];
        value.frame = CGRectMake(60, 5, [UIScreen mainScreen].bounds.size.width-30, 30);
        //content.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        self.valueTextField = value;
        
        [self.contentView addSubview:value];
        
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
