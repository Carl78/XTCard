//
//  CardDetailCell.m
//  CardRecognition
//
//  Created by sunshinek31 on 15/6/4.
//  Copyright (c) 2015年 bournejason. All rights reserved.
//

#import "CardDetailCell.h"

@implementation CardDetailCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        
    }
    return self;
}

-(void)setupTitle:(NSString *)title andContent:(NSString *)content {
    if (!self.titleLabel) {
        self.titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 50, 30)];
        self.titleLabel.text = title;
        self.titleLabel.center = CGPointMake(self.titleLabel.center.x, self.frame.size.height/2);
        [self.contentView addSubview:self.titleLabel];
    }else{
        if ([title isEqualToString:@"企业类型"]) {
            self.titleLabel.text = @"类型";
        }else{
            self.titleLabel.text = title;
        }
    }
    
    
    
    if (!self.contentLabel) {
        self.contentLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        self.contentLabel.numberOfLines = 2;
        
//        self.contentLabel.backgroundColor = [UIColor lightGrayColor];
        self.contentLabel.text = content;
        
        
        
        CGFloat width = self.frame.size.width - 10-50-20-30 ;
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            width = [UIScreen mainScreen].bounds.size.width - 10-50-20-30;
        }
        
//        [self.contentLabel sizeThatFits:CGSizeMake(width, self.frame.size.height)];
        
//        CGRect frame = self.contentLabel.frame;
        
        self.contentLabel.frame = CGRectMake(80, 0, width, self.frame.size.height );
        [self.contentLabel sizeThatFits:CGSizeMake(width, self.frame.size.height)];
        [self.contentView addSubview:self.contentLabel];
    }else{
        self.contentLabel.text = content;
    }
    

    
}

@end
