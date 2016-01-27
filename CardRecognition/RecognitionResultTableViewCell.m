//
//  RecognitionResultTableViewCell.m
//  CardRecognition
//
//  Created by bournejason on 15/5/17.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "RecognitionResultTableViewCell.h"

@implementation RecognitionResultTableViewCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //1 cell图标
        UILabel *title = [[UILabel alloc]init];
        title.frame = CGRectMake(10, 5, 50, 30);
        self.titleLabel = title;
        [self.contentView addSubview:title];
        
        //2 cell标题
        UILabel *content = [[UILabel alloc]init];
        CGFloat width = self.frame.size.width - 10-50-20-30 ;
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            width = [UIScreen mainScreen].bounds.size.width - 10-50-20-30;
        }else{
            if ([UIScreen mainScreen].bounds.size.width == 414) {
                width = [UIScreen mainScreen].bounds.size.width - 10-50-20-30;
            }
        }
        content.frame = CGRectMake(60, 5, width, 30);
        //content.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
        self.contentLabel = content;
        
        [self.contentView addSubview:content];
        
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
